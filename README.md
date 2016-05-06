# SpeedPro

1. 全球首款,支持宽带、网页和视频业务的质量监控。
2. 智能精准,一键式智能精准检测，仪表呈现，提供用户体验排名等强大功能。
3. 大数据分析,具备后台大数据分析能力，能够对整网进行专业的第三方质量排名。


分享环境配置说明:
一.Facebook分享AppID配置说明
发布版本时Bundle Id 为com.huawei.speedpro对应的AppID为576212805892427
测试版本时Bundle Id 为com.huawei.speedpro.debug,AppID为221368888244101
修改步骤:(两步)
1.打开AppDelegate.m文件
[UMSocialFacebookHandler setFacebookAppID:@"576212805892427" shareFacebookWithURL:Url];
将对应的数字替换.
2.Info.plist文件,右击选择Open As ->Source Code修改其中的两处字符串
        <key>CFBundleURLSchemes</key>
        <array>
        <string>fb576212805892427</string>
        </array>
        <key>FacebookAppID</key>
        <string>576212805892427</string>
将对应的数字替换.
