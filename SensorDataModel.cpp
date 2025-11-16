#include "SensorDataModel.h"
#include <QDebug>

// Constructor
SensorDataModel::SensorDataModel(QObject* parent) : QObject(parent) {
}

void SensorDataModel::updateIMU(double x, double y, double z, 
                                double roll, double pitch, double yaw) {
    // Store the new values
    m_imuX = x;
    m_imuY = y;
    m_imuZ = z;
    m_roll = roll;
    m_pitch = pitch;
    m_yaw = yaw;
    
    emit imuDataChanged();
}

void SensorDataModel::updateKalman(double rawAngle, double filteredAngle) {
    m_rawAngle = rawAngle;
    m_filteredAngle = filteredAngle;
    
    emit kalmanDataChanged();
}

void SensorDataModel::updateBaro(double pressure, double altitude) {
    m_pressure = pressure;
    m_altitude = altitude;
    
    emit baroDataChanged();
}

void SensorDataModel::updateTelemetry(double velocity, double temperature, 
                                      double signal, double battery) {
    m_velocity = velocity;
    m_temperature = temperature;
    m_signal = signal;
    m_battery = battery;
    
    emit telemetryDataChanged();
}
