
;; STX-VerdaVault

;; Constants
(define-constant contract-admin tx-sender)
(define-constant ERR_ADMIN_ONLY (err u100))
(define-constant ERR_DATA_NOT_FOUND (err u101))
(define-constant ERR_INVALID_INPUT (err u102))
(define-constant ERR_ALREADY_EXISTS (err u103))
(define-constant ERR_UNAUTHORIZED_ACTION (err u104))
(define-constant ERR_INVALID_CONSERVATION_STATUS (err u105))
(define-constant ERR_ZERO_VALUE (err u106))
(define-constant ERR_INVALID_ECOSYSTEM_ID (err u107))
(define-constant ERR_INVALID_SPECIES_ID (err u108))

;; Data structures
(define-map ecosystem-registry 
    { ecosystem-id: uint }
    {
        ecosystem-name: (string-ascii 50),
        geographic-region: (string-ascii 100),
        total-hectares: uint,
        creation-block-height: uint,
        last-updated-block-height: uint
    }
)

(define-map species-registry
    { species-id: uint }
    {
        common-species-name: (string-ascii 50),
        scientific-species-name: (string-ascii 100),
        current-population-count: uint,
        parent-ecosystem-id: uint,
        conservation-status: (string-ascii 20),
        last-population-census-block: uint
    }
)

(define-map ecosystem-biodiversity-summary
    { ecosystem-id: uint }
    {
        total-recorded-species: uint,
        biodiversity-complexity-index: uint,
        threatened-species-count: uint,
        last-biodiversity-assessment-block: uint
    }
)

;; Data storage
(define-data-var next-ecosystem-id uint u1)
(define-data-var next-species-id uint u1)
(define-data-var total-registered-ecosystems uint u0)
(define-data-var total-registered-species uint u0)

;; Authorization check
(define-private (is-contract-administrator)
    (is-eq tx-sender contract-admin)
)

;; Enhanced string validation function
(define-private (validate-string-input (input (string-ascii 100)))
    (let 
        (
            (input-length (len input))
        )
        (asserts! (> input-length u0) ERR_INVALID_INPUT)
        (asserts! (<= input-length u100) ERR_INVALID_INPUT)
        (ok input)
    )
)

;; Ecosystem management functions
(define-public (register-ecosystem 
                (ecosystem-name (string-ascii 50)) 
                (geographic-region (string-ascii 100)) 
                (total-hectares uint))
    (begin
        (asserts! (is-contract-administrator) ERR_ADMIN_ONLY)
        (asserts! (> (len ecosystem-name) u0) ERR_INVALID_INPUT)
        (asserts! (> total-hectares u0) ERR_ZERO_VALUE)

        (let
            (
                (new-ecosystem-id (var-get next-ecosystem-id))
                (validated-region (unwrap! (validate-string-input geographic-region) ERR_INVALID_INPUT))
            )
            ;; Check the validation result before using
            (asserts! (is-some (some validated-region)) ERR_INVALID_INPUT)

            (map-insert ecosystem-registry
                { ecosystem-id: new-ecosystem-id }
                {
                    ecosystem-name: ecosystem-name,
                    geographic-region: validated-region,
                    total-hectares: total-hectares,
                    creation-block-height: stacks-block-height,
                    last-updated-block-height: stacks-block-height
                }
            )

            (map-insert ecosystem-biodiversity-summary
                { ecosystem-id: new-ecosystem-id }
                {
                    total-recorded-species: u0,
                    biodiversity-complexity-index: u0,
                    threatened-species-count: u0,
                    last-biodiversity-assessment-block: stacks-block-height
                }
            )

            (var-set next-ecosystem-id (+ new-ecosystem-id u1))
            (var-set total-registered-ecosystems (+ (var-get total-registered-ecosystems) u1))
            (ok new-ecosystem-id)
        )
    )
)

(define-public (update-ecosystem-details 
                (ecosystem-id uint)
                (updated-name (string-ascii 50))
                (updated-region (string-ascii 100))
                (updated-hectares uint))
    (begin
        (asserts! (is-contract-administrator) ERR_ADMIN_ONLY)
        (asserts! (> (len updated-name) u0) ERR_INVALID_INPUT)
        (asserts! (> updated-hectares u0) ERR_ZERO_VALUE)
        (asserts! (is-ecosystem-registered ecosystem-id) ERR_INVALID_ECOSYSTEM_ID)

        (let
            (
                (existing-ecosystem-details (unwrap! (map-get? ecosystem-registry { ecosystem-id: ecosystem-id }) ERR_DATA_NOT_FOUND))
                (validated-region (unwrap! (validate-string-input updated-region) ERR_INVALID_INPUT))
            )
            ;; Check the validation result before using
            (asserts! (is-some (some validated-region)) ERR_INVALID_INPUT)

            (ok
                (map-set ecosystem-registry
                    { ecosystem-id: ecosystem-id }
                    {
                        ecosystem-name: updated-name,
                        geographic-region: validated-region,
                        total-hectares: updated-hectares,
                        creation-block-height: (get creation-block-height existing-ecosystem-details),
                        last-updated-block-height: stacks-block-height
                    }
                )
            )
        )
    )
)

;; Species management functions
(define-public (register-species 
                (common-species-name (string-ascii 50))
                (scientific-species-name (string-ascii 100))
                (initial-population-count uint)
                (parent-ecosystem-id uint)
                (conservation-status (string-ascii 20)))
    (begin
        (asserts! (is-contract-administrator) ERR_ADMIN_ONLY)
        (asserts! (> (len common-species-name) u0) ERR_INVALID_INPUT)
        (asserts! (> initial-population-count u0) ERR_ZERO_VALUE)
        (asserts! (is-ecosystem-registered parent-ecosystem-id) ERR_INVALID_ECOSYSTEM_ID)
        (asserts! (or (is-eq conservation-status "threatened")
                     (is-eq conservation-status "stable")
                     (is-eq conservation-status "endangered")
                     (is-eq conservation-status "extinct")) ERR_INVALID_CONSERVATION_STATUS)

        (let
            (
                (new-species-id (var-get next-species-id))
                (current-ecosystem-biodiversity (unwrap! (map-get? ecosystem-biodiversity-summary { ecosystem-id: parent-ecosystem-id }) ERR_DATA_NOT_FOUND))
                (validated-scientific-name (unwrap! (validate-string-input scientific-species-name) ERR_INVALID_INPUT))
            )
            ;; Check the validation result before using
            (asserts! (is-some (some validated-scientific-name)) ERR_INVALID_INPUT)

            (map-insert species-registry
                { species-id: new-species-id }
                {
                    common-species-name: common-species-name,
                    scientific-species-name: validated-scientific-name,
                    current-population-count: initial-population-count,
                    parent-ecosystem-id: parent-ecosystem-id,
                    conservation-status: conservation-status,
                    last-population-census-block: stacks-block-height
                }
            )

            (map-set ecosystem-biodiversity-summary
                { ecosystem-id: parent-ecosystem-id }
                {
                    total-recorded-species: (+ (get total-recorded-species current-ecosystem-biodiversity) u1),
                    biodiversity-complexity-index: (+ (get biodiversity-complexity-index current-ecosystem-biodiversity) u1),
                    threatened-species-count: (if (is-eq conservation-status "threatened")
                                             (+ (get threatened-species-count current-ecosystem-biodiversity) u1)
                                             (get threatened-species-count current-ecosystem-biodiversity)),
                    last-biodiversity-assessment-block: stacks-block-height
                }
            )

            (var-set next-species-id (+ new-species-id u1))
            (var-set total-registered-species (+ (var-get total-registered-species) u1))
            (ok new-species-id)
        )
    )
)

(define-public (update-species-population 
                (species-id uint)
                (updated-population-count uint)
                (updated-conservation-status (string-ascii 20)))
    (let
        (
            (current-species-details (unwrap! (map-get? species-registry { species-id: species-id }) ERR_DATA_NOT_FOUND))
            (current-ecosystem-biodiversity (unwrap! (map-get? ecosystem-biodiversity-summary 
                { ecosystem-id: (get parent-ecosystem-id current-species-details) }) ERR_DATA_NOT_FOUND))
        )
        (asserts! (is-contract-administrator) ERR_ADMIN_ONLY)
        (asserts! (>= updated-population-count u0) ERR_INVALID_INPUT)
        (asserts! (or (is-eq updated-conservation-status "threatened")
                     (is-eq updated-conservation-status "stable")
                     (is-eq updated-conservation-status "endangered")
                     (is-eq updated-conservation-status "extinct")) ERR_INVALID_CONSERVATION_STATUS)
        (asserts! (is-species-registered species-id) ERR_INVALID_SPECIES_ID)

        (map-set species-registry
            { species-id: species-id }
            {
                common-species-name: (get common-species-name current-species-details),
                scientific-species-name: (get scientific-species-name current-species-details),
                current-population-count: updated-population-count,
                parent-ecosystem-id: (get parent-ecosystem-id current-species-details),
                conservation-status: updated-conservation-status,
                last-population-census-block: stacks-block-height
            }
        )

        ;; Update threatened species count if status changed
        (if (not (is-eq (get conservation-status current-species-details) updated-conservation-status))
            (map-set ecosystem-biodiversity-summary
                { ecosystem-id: (get parent-ecosystem-id current-species-details) }
                {
                    total-recorded-species: (get total-recorded-species current-ecosystem-biodiversity),
                    biodiversity-complexity-index: (get biodiversity-complexity-index current-ecosystem-biodiversity),
                    threatened-species-count: (if (is-eq updated-conservation-status "threatened")
                                             (+ (get threatened-species-count current-ecosystem-biodiversity) u1)
                                             (- (get threatened-species-count current-ecosystem-biodiversity) u1)),
                    last-biodiversity-assessment-block: stacks-block-height
                }
            )
            true
        )
        (ok true)
    )
)

;; Read-only functions
(define-read-only (get-ecosystem-details (ecosystem-id uint))
    (map-get? ecosystem-registry { ecosystem-id: ecosystem-id })
)

(define-read-only (get-species-details (species-id uint))
    (map-get? species-registry { species-id: species-id })
)

(define-read-only (get-ecosystem-biodiversity-summary (ecosystem-id uint))
    (map-get? ecosystem-biodiversity-summary { ecosystem-id: ecosystem-id })
)

(define-read-only (get-total-ecosystems)
    (ok (var-get total-registered-ecosystems))
)

(define-read-only (get-total-species)
    (ok (var-get total-registered-species))
)

;; Helper functions
(define-read-only (is-ecosystem-registered (ecosystem-id uint))
    (is-some (map-get? ecosystem-registry { ecosystem-id: ecosystem-id }))
)

(define-read-only (is-species-registered (species-id uint))
    (is-some (map-get? species-registry { species-id: species-id }))
)