# DBDeviceInfo
设备信息获取.
现在要想取得一个不会变的设备唯一标示，在上架的前提下已经取不到了。能替代的只有IDFA，IDFV。
广告标示符（IDFA-identifierForIdentifier）。需要导入AdSupport.framework

NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
广告标示符是由系统存储着的。不过即使这是由系统存储的，但是有几种情况下，会重新生成广告标示符。如果用户完全重置系统（(设置程序 -> 通用 -> 还原 -> 还原位置与隐私) ，这个广告标示符会重新生成。另外如果用户明确的还原广告(设置程序-> 通用 -> 关于本机 -> 广告 -> 还原广告标示符) ，那么广告标示符也会重新生成。关于广告标示符的还原，有一点需要注意：如果程序在后台运行，此时用户“还原广告标示符”，然后再回到程序中，此时获取广告标示符并不会立即获得还原后的标示符。必须要终止程序，然后再重新启动程序，才能获得还原后的广告标示符。
针对广告标示符用户有一个可控的开关“限制广告跟踪”，打开后获取不到IDFA。

Vindor标示符 (IDFV-identifierForVendor)
NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

vendor非常简单：一个Vendor是CFBundleIdentifier（反转DNS格式）的前两部分。例如，com.rs.app1 和 com.rs.app2 得到的identifierForVendor是相同的，因为它们的CFBundleIdentifier 前两部分是相同的。不过这样获得的identifierForVendor则完全不同：com.rs 或 net.rs。

在这里，还需要注意的一点就是,如果用户卸载了同一个vendor对应的所有程序，然后在重新安装同一个vendor提供的程序，此时identifierForVendor会被重置。

总结，那么获取到的这个属性值就不会变：相同的一个程序里面-相同的vindor-相同的设备。如果是这样的情况，那么这个值是不会相同的：相同的程序-相同的设备-不同的vindor，或者是相同的程序-不同的设备-无论是否相同的vindor。
