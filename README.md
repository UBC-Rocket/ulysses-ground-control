# Ulysses Ground Control Station (GCS)
### *Real-Time Telemetry • Serial Radio Interface • 3D Rocket Visualization*

The **Ulysses Ground Control Station** is a cross-platform telemetry and control application built with **Qt 6**, designed for UBC Rocket's development and mission operations.  
It provides real-time serial communication with RFD900x radio modems, sensor telemetry decoding, 3D visual orientation, system alerts, and modular UI panels optimized for engineering workflows.

---

## 🚀 Features

### 📡 Dual-Mode Serial Communication

#### **1. Single-Port Mode**
- One COM port handles **both RX and TX**
- Automatic **RX pause** during TX to prevent echo/loopback issues
- Ideal for bench testing with a single modem

#### **2. Dual-Port Mode**
- Dedicated RX and TX ports
- Per-port capabilities:
  - Separate baud settings
  - Periodic command sender (1–200 Hz)
  - Manual send panel
  - Real-time text logging
  - Independent connect/disconnect

---

### 📶 RFD900x Modem Integration
- Automatic scanning of COM ports
- FTDI + CP210x radio-adapter detection
- AT-mode probing (`+++` guard sequence)
- OS error reporting displayed in UI
- Prevents assigning same port to both P1 and P2

---

### 📊 Sensor Telemetry Parsing

Incoming telemetry is 14-field CSV:
x, y, z,
roll, pitch, yaw,
pressure, altitude,
raw_angle, filtered_angle,
velocity, temperature, signal, battery


Decoded into:

- **IMU:** linear accel (x,y,z) + gyro (roll, pitch, yaw)
- **Barometer:** pressure, altitude
- **Kalman:** raw angle, filtered angle
- **Telemetry:** velocity, temperature, signal, battery

Each value updates QML-bound properties via `SensorDataModel`.

---

### 🛰️ 3D Rocket Visualization
Built with **Qt Quick 3D**:

- Real-time orientation driven by IMU data  
- Euler rotation mapped for Qt’s Y-up coordinate system  
- Axis helper lines  
- WASD camera movement  
- Clear visualization of rocket tilt/roll

---

### ⚠️ System Alert Classification
Using `AlarmReceiver`, incoming text is classified into:

- **ERROR**
- **WARNING**
- **SUCCESS**

Displayed visually as alert chips in the System Alert panel.

---

### 🧱 Modular Architecture

#### Backend (C++)
| Component            | Description                                      |
|---------------------|--------------------------------------------------|
| `SerialBridge`       | Serial I/O layer, port scanning, RX/TX, modem detection |
| `CommandSender`      | Manual & periodic command transmission           |
| `AlarmReceiver`      | Classifies incoming text messages                |
| `SensorDataModel`    | Parses CSV telemetry, exposes data to QML        |

#### Frontend (QML)
| File                               | Purpose                          |
|-----------------------------------|----------------------------------|
| `Panel_Control.qml`               | Serial configuration + TX console |
| `Panel_IMU_Data.qml`              | IMU vector display               |
| `Panel_Baro_And_Telemetry.qml`    | Pressure, altitude, velocity, temp |
| `Panel_Rocket_Visualization.qml`  | 3D visualization of rocket        |
| `Panel_System_Alert.qml`          | Error/Warning/Success logs        |
| `Items/`                          | Reusable UI components            |

---

## 📁 Project Structure

/
├── src/
│ ├── SerialBridge.h/.cpp
│ ├── CommandSender.h/.cpp
│ ├── AlarmReceiver.h/.cpp
│ ├── SensorDataModel.h/.cpp
│ └── main.cpp
│
└── qml/
├── Panel_Control.qml
├── Panel_IMU_Data.qml
├── Panel_Baro_And_Telemetry.qml
├── Panel_Rocket_Visualization.qml
├── Panel_System_Alert.qml
├── Items/
└── MainWindow.qml

---

## 🧰 Build Instructions

### Requirements
- Qt **6.6+** (must include Qt Quick and Qt Quick 3D)
- CMake (Qt Creator recommended)
- Windows / macOS / Linux

### Build using Qt Creator
File → Open Project → CMakeLists.txt
Configure Kits → Desktop Qt 6.x.x
Build → Run

### Build using terminal
```bash
cmake -B build -S .
cmake --build build
./build/ulysses-ground-control     # or .exe on Windows
