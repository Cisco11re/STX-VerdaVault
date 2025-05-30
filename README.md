
#  STX-VerdaVault -Tracking Contract

A smart contract written in Clarity to **track, manage, and assess biodiversity data across ecosystems**. This system is designed for conservation efforts, environmental data analysis, and decentralized ecological record-keeping.

---

## 📘 Overview

This smart contract enables a trusted administrator to:

* Register ecosystems and species
* Update species population and conservation statuses
* Track biodiversity metrics across ecosystems

It's designed for **environmental organizations**, **research institutions**, and **government agencies** that need an immutable and transparent method of tracking ecosystem and species data on the Stacks blockchain.

---

## ⚙️ Features

### ✅ Ecosystem Management

* **Register a new ecosystem**
* **Update existing ecosystem details**
* Tracks:

  * Name
  * Geographic region
  * Area in hectares
  * Timestamps for creation and updates

### 🐾 Species Management

* **Register a species under an ecosystem**
* **Update species population and conservation status**
* Records:

  * Common and scientific names
  * Conservation status (threatened, stable, endangered, extinct)
  * Population count
  * Last census block height

### 📊 Biodiversity Summarization

* Tracks key biodiversity indicators per ecosystem:

  * Total species
  * Threatened species count
  * Biodiversity complexity index

### 🔐 Access Control

* Only the **contract administrator** (initial deployer) can perform mutative actions

### 🔎 Read-Only Views

* Fetch data for:

  * Individual ecosystems or species
  * Biodiversity summary per ecosystem
  * Total registered ecosystems and species

---

## 🧠 Contract Logic Summary

### Constants

Defined error codes and contract administrator identity.

### Maps & Data Vars

* `ecosystem-registry`: Stores ecosystem metadata
* `species-registry`: Stores species data
* `ecosystem-biodiversity-summary`: Stores per-ecosystem biodiversity data
* `next-ecosystem-id`, `next-species-id`: Auto-incrementing IDs
* `total-registered-ecosystems`, `total-registered-species`: Global counters

### Public Functions

| Function                    | Description                                        |
| --------------------------- | -------------------------------------------------- |
| `register-ecosystem`        | Registers a new ecosystem                          |
| `update-ecosystem-details`  | Updates metadata of an existing ecosystem          |
| `register-species`          | Registers a species under an ecosystem             |
| `update-species-population` | Updates species population and conservation status |

### Read-Only Functions

| Function                             | Description                                   |
| ------------------------------------ | --------------------------------------------- |
| `get-ecosystem-details`              | Fetch ecosystem data                          |
| `get-species-details`                | Fetch species data                            |
| `get-ecosystem-biodiversity-summary` | Fetch biodiversity summary                    |
| `get-total-ecosystems`               | Returns total number of registered ecosystems |
| `get-total-species`                  | Returns total number of registered species    |
| `is-ecosystem-registered`            | Checks if an ecosystem exists                 |
| `is-species-registered`              | Checks if a species exists                    |

---

## 🚫 Errors & Validations

| Error Code | Meaning                     |
| ---------- | --------------------------- |
| `u100`     | Admin-only operation        |
| `u101`     | Data not found              |
| `u102`     | Invalid input               |
| `u103`     | Already exists              |
| `u104`     | Unauthorized action         |
| `u105`     | Invalid conservation status |
| `u106`     | Zero value provided         |
| `u107`     | Invalid ecosystem ID        |
| `u108`     | Invalid species ID          |

---

## 🛡️ Security Notes

* **Only the contract deployer** (administrator) is allowed to register and update data.
* **Input validation** ensures data consistency and restricts invalid inputs.

---

## 📦 Deployment

Deploy on the [Stacks blockchain](https://docs.stacks.co/) using a supported development tool like [Clarinet](https://docs.stacks.co/clarity/clarinet-cli/overview).

---

## 🧪 Example Use Cases

* Decentralized biodiversity audit records
* Public registry for conservation NGOs
* Environmental monitoring apps using blockchain as backend
* Immutable habitat loss tracking systems

---
