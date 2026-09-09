//
//  HelperFunc.swift
//  Self Assembling Sugar
//
//  Created by David Nishimoto on 9/9/26.
//

import Foundation
import SceneKit


extension SCNVector3 {

    static func + (
        lhs: SCNVector3,
        rhs: SCNVector3
    ) -> SCNVector3 {

        return SCNVector3(
            lhs.x + rhs.x,
            lhs.y + rhs.y,
            lhs.z + rhs.z
        )
    }

    static func - (
        lhs: SCNVector3,
        rhs: SCNVector3
    ) -> SCNVector3 {

        return SCNVector3(
            lhs.x - rhs.x,
            lhs.y - rhs.y,
            lhs.z - rhs.z
        )
    }

    static func * (
        lhs: SCNVector3,
        rhs: Float
    ) -> SCNVector3 {

        return SCNVector3(
            lhs.x * rhs,
            lhs.y * rhs,
            lhs.z * rhs
        )
    }

    func length() -> Float {

        return sqrt(
            x * x +
            y * y +
            z * z
        )
    }

    func normalized() -> SCNVector3 {

        let value =
            length()

        guard value > 0.0001 else {
            return SCNVector3(
                0,
                0,
                0
            )
        }

        return self *
            (
                1.0 /
                value
            )
    }

    func dot(
        _ other: SCNVector3
    ) -> Float {

        return
            x * other.x +
            y * other.y +
            z * other.z
    }

    func cross(
        _ other: SCNVector3
    ) -> SCNVector3 {

        return SCNVector3(
            y * other.z -
                z * other.y,

            z * other.x -
                x * other.z,

            x * other.y -
                y * other.x
        )
    }
}
