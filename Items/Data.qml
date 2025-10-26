import QtQuick

Item {

    // property alias IMU: data_IMU

    //IMU Data
    Item {
        id:data_IMU
        property double x_axis
        property double y_axis
        property double z_axis
        property double roll
        property double pitch
        property double yaw
    }

    //Kalman Data
    Item {
        property double raw_angle
        property double filtered_angle
    }

    //Rocket Visualization Data


    //Telemetry Data
    Item {
        property double velocity
        property double altitude
        property double temperature
        property double signal
        property double battery
    }

    //Barometer Data
    Item {
        property double pressure
        property double altitude
    }


    //Engine Data
    Item {
        property double throttle
        property double fuel
    }

}
