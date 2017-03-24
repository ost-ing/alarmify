//
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import "AudioHelper.h"
#import "CoreAudio/CoreAudio.h"

@implementation AudioHelper

/**
 * Determine if the computer is using the internal or an external sound source
 */
+ (BOOL) isUsingInternalOutputSystem
{
    // Determine if the data-source is using the internal output system
    AudioDeviceID deviceID = 0;
    UInt32 theSize = sizeof(AudioDeviceID);
    AudioObjectPropertyAddress theAddress =
    {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeOutput, // Was global
        kAudioObjectPropertyElementMaster
    };
    OSStatus err = AudioObjectGetPropertyData(kAudioObjectSystemObject, &theAddress, 0, NULL, &theSize, &deviceID);
    if (err != noErr) return false;
    
    // Attempt to access the volume scalar of the input output system
    UInt32 inChannel = 1;
    Float32 data = 0;
    theSize = sizeof(Float32);
    AudioObjectPropertyAddress volumeAddress =
    {
        kAudioDevicePropertyVolumeScalar,
        kAudioDevicePropertyScopeOutput,
        inChannel
    };
    err = AudioObjectGetPropertyData(deviceID, &volumeAddress, 0, NULL, &theSize, &data);
    if (err != noErr) return false;

    return true;
}


@end
