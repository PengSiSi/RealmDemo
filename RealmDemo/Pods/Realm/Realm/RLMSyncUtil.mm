////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

#import "RLMSyncConfiguration_Private.hpp"
#import "RLMSyncUtil_Private.hpp"
#import "RLMSyncUser_Private.hpp"
#import "RLMRealmConfiguration+Sync.h"
#import "RLMRealmConfiguration_Private.hpp"
#import "RLMSyncPermission.h"
#import "RLMSyncPermissionChange.h"
#import "RLMSyncPermissionOffer.h"
#import "RLMSyncPermissionOfferResponse.h"

#import "shared_realm.hpp"

#import "sync/sync_user.hpp"

static RLMRealmConfiguration *RLMRealmSpecialPurposeConfiguration(RLMSyncUser *user, NSString *realmName) {
    NSURLComponents *components = [NSURLComponents componentsWithURL:user.authenticationServer resolvingAgainstBaseURL:NO];
    if ([components.scheme isEqualToString:@"https"]) {
        components.scheme = @"realms";
    } else {
        components.scheme = @"realm";
    }
    components.path = [NSString stringWithFormat:@"/~/%@", realmName];
    NSURL *realmURL = components.URL;
    RLMSyncConfiguration *syncConfig = [[RLMSyncConfiguration alloc] initWithUser:user realmURL:realmURL];
    RLMRealmConfiguration *config = [RLMRealmConfiguration new];
    config.syncConfiguration = syncConfig;
    return config;
}

@implementation RLMRealmConfiguration (RealmSync)
+ (instancetype)managementConfigurationForUser:(RLMSyncUser *)user {
    RLMRealmConfiguration *config = RLMRealmSpecialPurposeConfiguration(user, @"__management");
    config.objectClasses = @[RLMSyncPermissionChange.class, RLMSyncPermissionOffer.class, RLMSyncPermissionOfferResponse.class];
    return config;
}

+ (instancetype)permissionConfigurationForUser:(RLMSyncUser *)user {
    RLMRealmConfiguration *config = RLMRealmSpecialPurposeConfiguration(user, @"__permission");
    config.objectClasses = @[RLMSyncPermission.class];
    return config;
}
@end

RLMIdentityProvider const RLMIdentityProviderAccessToken = @"_access_token";

NSString *const RLMSyncErrorDomain = @"io.realm.sync";

NSString *const kRLMSyncPathOfRealmBackupCopyKey            = @"recovered_realm_location_path";
NSString *const kRLMSyncInitiateClientResetBlockKey         = @"initiate_client_reset_block";

NSString *const kRLMSyncAppIDKey                = @"app_id";
NSString *const kRLMSyncDataKey                 = @"data";
NSString *const kRLMSyncErrorJSONKey            = @"json";
NSString *const kRLMSyncErrorStatusCodeKey      = @"statusCode";
NSString *const kRLMSyncIdentityKey             = @"identity";
NSString *const kRLMSyncPasswordKey             = @"password";
NSString *const kRLMSyncPathKey                 = @"path";
NSString *const kRLMSyncProviderKey             = @"provider";
NSString *const kRLMSyncRegisterKey             = @"register";
NSString *const kRLMSyncUnderlyingErrorKey      = @"underlying_error";

namespace realm {

SyncSessionStopPolicy translateStopPolicy(RLMSyncStopPolicy stopPolicy) {
    switch (stopPolicy) {
        case RLMSyncStopPolicyImmediately:              return SyncSessionStopPolicy::Immediately;
        case RLMSyncStopPolicyLiveIndefinitely:         return SyncSessionStopPolicy::LiveIndefinitely;
        case RLMSyncStopPolicyAfterChangesUploaded:     return SyncSessionStopPolicy::AfterChangesUploaded;
    }
    REALM_UNREACHABLE();    // Unrecognized stop policy.
}

RLMSyncStopPolicy translateStopPolicy(SyncSessionStopPolicy stop_policy)
{
    switch (stop_policy) {
        case SyncSessionStopPolicy::Immediately:            return RLMSyncStopPolicyImmediately;
        case SyncSessionStopPolicy::LiveIndefinitely:       return RLMSyncStopPolicyLiveIndefinitely;
        case SyncSessionStopPolicy::AfterChangesUploaded:   return RLMSyncStopPolicyAfterChangesUploaded;
    }
    REALM_UNREACHABLE();
}

std::shared_ptr<SyncSession> sync_session_for_realm(RLMRealm *realm)
{
    Realm::Config realmConfig = realm.configuration.config;
    if (auto config = realmConfig.sync_config) {
        std::shared_ptr<SyncUser> user = config->user;
        if (user && user->state() != SyncUser::State::Error) {
            return user->session_for_on_disk_path(realmConfig.path);
        }
    }
    return nullptr;
}

}

RLMSyncManagementObjectStatus RLMMakeSyncManagementObjectStatus(NSNumber<RLMInt> *statusCode) {
    if (!statusCode) {
        return RLMSyncManagementObjectStatusNotProcessed;
    }
    if (statusCode.integerValue == 0) {
        return RLMSyncManagementObjectStatusSuccess;
    }
    return RLMSyncManagementObjectStatusError;
}
