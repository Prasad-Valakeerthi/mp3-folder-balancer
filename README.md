# MP3 Folder Balancer

Automatically organizes MP3 files into numbered folders (1,2,3...) with a maximum of 255 files per folder.  
Designed for USB drives used in car stereos and media players.

---

## 🔧 Features

- Keeps **max 255 MP3 files per folder**
- Maintains **alphabetical order**
- Automatically **moves overflow files** to next folders
- Creates new folders if required (n → n+1)
- Works with **large collections (10,000+ files)**
- Safe: **only touches .mp3 files**
- Validates folder structure before running

---

## 📁 Required Folder Structure

Your USB drive must look like this:
F:
├─ 1
├─ 2
├─ 3
├─ 4


- Folder names must be **numbers only**
- No extra folders allowed

---

## 🚀 How to Use (Easy Method)

### 1. Download script (first time only)

Run in PowerShell:

irm https://raw.githubusercontent.com/USERNAME/mp3-folder-balancer/main/mp3-folder-balancer.ps1
 -OutFile "$env:USERPROFILE\Documents\mp3-folder-balancer.ps1"

 
---

### 2. Run script

powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Documents\mp3-folder-balancer.ps1" -root F:\


---

## 🔁 Auto Update + Offline Mode (Recommended)

Use the helper script (`mp3-tool.ps1`) to:

- Auto-detect USB
- Work offline
- Auto-update when internet is available

---

## ⚙️ Configuration

| Setting | Description | Example |
|--------|------------|--------|
| `$root` | USB drive path | `F:\` |
| `$limit` | Max files per folder | `255` |

---

## ⚠️ Rules

- Only `.mp3` files are processed
- Other files are ignored
- If folder structure is invalid → script will stop
- Requires PowerShell (Windows)

---

## 🧠 Example

### Before
1 → 280 files
2 → 260 files
3 → 255 files

### After
1 → 255
2 → 255
3 → 255
4 → 30

---

## 📌 Notes

- Designed for **car USB music systems**
- Works best with **alphabetically named files**
- Safe to run multiple times

---

## 📄 License

Free to use and modify.
