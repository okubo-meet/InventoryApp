//
//  SoundPlayer.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/05/05.
//

import UIKit
import AudioToolbox

///サウンドを扱うクラス
class SoundPlayer {
    //データ保存時の効果音ID
    private var saveSound: SystemSoundID = 1300
    //データ削除時の効果音ID
    private var deleteSound: SystemSoundID = 1050
    //バーコード検知時の効果音ID
    private var detectSound: SystemSoundID = 1057
    
    ///データ保存の効果音を再生する関数
    func saveSound_play() {
        if let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil) {
            AudioServicesCreateSystemSoundID(soundURL, &saveSound)
            AudioServicesPlaySystemSound(saveSound)
        }
    }
    ///データ削除の効果音を再生する関数
    func deleteSound_play() {
        if let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil) {
            AudioServicesCreateSystemSoundID(soundURL, &deleteSound)
            AudioServicesPlaySystemSound(deleteSound)
        }
    }
    ///バーコード検知の効果音を再生する関数
    func detectSound_play() {
        if let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil) {
            AudioServicesCreateSystemSoundID(soundURL, &detectSound)
            AudioServicesPlaySystemSound(detectSound)
        }
    }
}
