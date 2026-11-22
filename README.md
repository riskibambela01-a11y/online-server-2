# Mod Loader System - Complete Reference Guide

## Overview

This document provides a comprehensive reference for the Mod Loader System used in Lua-based game development frameworks. The system enables dynamic loading and execution of modular Lua code from remote sources, facilitating seamless updates and feature additions without requiring full game redeployment.

The architecture is designed to work within sandboxed Lua environments commonly found in modern game engines, utilizing HTTP-based content delivery and chunked loading strategies for reliability and performance.

---

## Author and Community

**Developer:** Sachin (Alias: XThrlen)
**Community:** SRCHUB
**Established:** 2017
**Origin:** India
**Reach:** Global

SRCHUB is a globally recognized community of developers specializing in game modification, reverse engineering, automation tools, and advanced Lua scripting. With roots dating back to 2017, SRCHUB has contributed numerous open-source tools and educational resources to the developer community.

---

## System Architecture

### 1. Client-Side Mod Loader

The client-side loader integrates into the game's character base class and manages the lifecycle of mod chunks.

#### Core Class Structure

**File:** `BRPlayerCharacterBase.lua`

| Component | Description |
|-----------|-------------|
| `BRPlayerCharacterBase` | Main character class extending `CharacterBase` |
| `ServerRPC` | Server-side remote procedure calls |
| `ClientRPC` | Client-side RPC definitions |
| `MulticastRPC` | Multicast RPC for synchronized execution |

### 2. Cloudflare Worker Proxy

**File:** `server.js`

The Cloudflare Worker acts as a proxy between the game client and GitHub's raw content delivery, providing:

- **No authentication required** for public repositories
- **CORS support** for cross-origin requests
- **.lua file filtering** for security
- **Error handling and retry logic** at the network layer

---

## API Reference

### Client-Side Functions

#### `BRPlayerCharacterBase:_PostConstruct()`

Initializes the mod loading system when the character is constructed on the client.

**Internal Variables:**

| Variable | Type | Description |
|----------|------|-------------|
| `MOD_URL` | `string` | Worker endpoint URL (must end with `/`) |
| `_G._ModChunks` | `table` | Global table storing loaded Lua chunks |
| `_G._MOD_EXECUTED` | `boolean` | Flag indicating successful execution |
| `CHUNKS_TO_FETCH` | `table` | Array of chunk IDs to load sequentially |
| `MAX_RETRIES_PER_CHUNK` | `number` | Maximum retry attempts per chunk (default: 5) |
| `MAX_TIMER_ATTEMPTS` | `number` | Maximum timer callback attempts (default: 60) |

#### `fetchChunk(n, retryCount)`

Asynchronously fetches and loads a specific chunk.

**Parameters:**
- `n` (`number`): Chunk identifier
- `retryCount` (`number`, optional): Current retry attempt counter

**Behavior:**
1. Sends POST request to `MOD_URL` with `key_path=n.lua`
2. Validates response length (> 50 characters)
3. Loads chunk using `load()`
4. Executes entry chunk immediately
5. Recursively fetches remaining chunks

#### `retryTimerCallback()`

Timer-based fallback mechanism for chunk loading.

**Returns:** `boolean` - `true` to continue timer, `false` to stop

**Logic:**
- Checks if mod already executed
- Increments attempt counter
- Triggers fetch if chunk missing
- Re-executes loaded chunk if needed

---

## Configuration Guide

### Step 1: Setup Cloudflare Worker

1. Create a new Cloudflare Worker
2. Deploy the following code:

```javascript
// server.js - Configuration
const REPO_OWNER = "riskibambela01-a11y";    // Your GitHub username
const REPO_NAME = "online-server-2";         // Your repository name
const BRANCH = "main";                // Branch (main/master)
