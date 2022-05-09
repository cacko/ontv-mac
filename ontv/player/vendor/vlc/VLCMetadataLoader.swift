//
//  VLCMetadataLoader.swift
//  craptv
//
//  Created by Alex on 30/10/2021.
//

import Foundation
import VLCKit

extension PlayerVLCKit {
  
  func loadMetadata() {
    logger.debug("loading metadata")
    for track in self.media.tracksInformation {
      guard let info = track as AnyObject? else {
        continue
      }
      
      guard let trackType = info["type"] as? String else {
        continue
      }
      
      switch trackType {
      case "video":
        self.controller.metadata.video = StreamInfo.Video(
          codec: VLCMedia.codecName(
            forFourCC: info[VLCMediaTracksInformationCodec] as! UInt32,
            trackType: trackType
          ),
          resolution: NSSize(
            width: info[VLCMediaTracksInformationVideoWidth] as! Int,
            height: info[VLCMediaTracksInformationVideoHeight] as! Int
          )
        )
        self.controller.metadataState = .loaded
        break
      case "audio":
        self.controller.metadata.audio = StreamInfo.Audio(
          codec: VLCMedia.codecName(
            forFourCC: info[VLCMediaTracksInformationCodec] as! UInt32,
            trackType: trackType
          ),
          channels: info[VLCMediaTracksInformationAudioChannelsNumber] as! Int,
          rate: info[VLCMediaTracksInformationAudioRate] as! Int
        )
        self.controller.metadataState = .loaded
        break
      default:
        break
      }
    }
  }
}
