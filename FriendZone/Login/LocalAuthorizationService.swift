//
//  LocalAuthorizationService.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import Foundation
import LocalAuthentication

class LocalAuthorizationService {
    var context = LAContext()
    var biometricType: Int = 0
    
    func isFaceIdSupported() {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            if context.biometryType == .faceID {
                self.biometricType = 2
            } else if context.biometryType == .touchID {
                self.biometricType = 1
            } else {
                self.biometricType = 0
            }
    }
    
    func authorizeIfPossible(_ authorizationFinished: @escaping (Bool?, Error?) -> Void) {
        
        var error: NSError?
        let canUseBiometricks = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if let error = error as? LAError {
            print(error)
            authorizationFinished(nil, error)
        }
        
        print(biometricType)
        guard canUseBiometricks else {
            authorizationFinished(false, nil)
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Войти с помощью пароля") { success, error in
            if let error = error {
                print(error)
                authorizationFinished(nil, error)
            }
            if success {
                authorizationFinished(true, nil)
            } else {
                authorizationFinished(false, nil)
            }
        }
    }
}
