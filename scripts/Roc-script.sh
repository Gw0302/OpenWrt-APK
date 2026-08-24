# 修改默认IP
sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate
#固件名称
sed -i "s/hostname='.*'/hostname='OpenWrt'/g" package/base-files/files/bin/config_generate
# 编译署名和时间
# sed -i "s#_('Firmware Version'), (L\.isObject(boardinfo\.release) ? boardinfo\.release\.description + ' / ' : '') + (luciversion || ''),# \
#            _('Firmware Version'),\n \
#            E('span', {}, [\n \
#                (L.isObject(boardinfo.release)\n \
#                ? boardinfo.release.description + ' / '\n \
#                : '') + (luciversion || '') + ' / ',\n \
#            E('a', {\n \
#                href: 'https://github.com/Lang-Ke/OpenWrt-ORC/releases',\n \
#                target: '_blank',\n \
#                rel: 'noopener noreferrer'\n \
#                }, [ 'Built by Roc $(date "+%Y-%m-%d %H:%M:%S")' ])\n \
#            ]),#" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# 移除luci-app-attendedsysupgrade软件包
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 调整NSS驱动q6_region内存区域预留大小（ipq6018.dtsi默认预留85MB，ipq6018-512m.dtsi默认预留55MB，带WiFi必须至少预留54MB，以下分别是改成预留16MB、32MB、64MB和96MB）
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x01000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x02000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x04000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi
# sed -i 's/reg = <0x0 0x4ab00000 0x0 0x[0-9a-f]\+>/reg = <0x0 0x4ab00000 0x0 0x06000000>/' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-512m.dtsi

# 移除要替换的包
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-wechatpush
rm -rf feeds/luci/applications/luci-app-appfilter
rm -rf feeds/luci/applications/luci-app-watchcat
rm -rf feeds/luci/applications/luci-app-frpc
rm -rf feeds/luci/applications/luci-app-frps
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/net/open-app-filter
rm -rf feeds/packages/net/ariang
rm -rf feeds/packages/net/frp
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/utils/watchcat

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# ariang & frp & Watchcat & WolPlus & Argon & Aurora & Go & OpenList & Lucky & wechatpush & OpenAppFilter & 集客无线AC控制器 & 雅典娜LED控制
git_sparse_clone ariang https://github.com/laipeng668/packages net/ariang
git_sparse_clone frp https://github.com/laipeng668/packages net/frp
mv -f package/frp feeds/packages/net/frp
git_sparse_clone frp https://github.com/laipeng668/luci applications/luci-app-frpc applications/luci-app-frps
mv -f package/luci-app-frpc feeds/luci/applications/luci-app-frpc
mv -f package/luci-app-frps feeds/luci/applications/luci-app-frps
git_sparse_clone openwrt-23.05 https://github.com/immortalwrt/packages utils/watchcat
mv -f package/watchcat feeds/packages/utils/watchcat
git_sparse_clone openwrt-23.05 https://github.com/immortalwrt/luci applications/luci-app-watchcat
mv -f package/luci-app-watchcat feeds/luci/applications/luci-app-watchcat
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon feeds/luci/themes/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config feeds/luci/applications/luci-app-argon-config
git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora feeds/luci/themes/luci-theme-aurora
git clone --depth=1 https://github.com/eamonxg/luci-app-aurora-config feeds/luci/applications/luci-app-aurora-config
git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/luci-app-openlist2 package/openlist2
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/luci-app-lucky
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush package/luci-app-wechatpush
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone --depth=1 https://github.com/lwb1978/openwrt-gecoosac package/openwrt-gecoosac
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-momo package/momo
git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki package/nikki
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led


# ========== 拉取adguardhome ui界面 ==========
./scripts/feeds update -a
# 移除源码自带的版本
rm -rf feeds/luci/applications/luci-app-adguardhome
# 克隆
git clone --depth=1 https://github.com/sirpdboy/luci-app-adguardhome temp-luci-adguard
cp -rf temp-luci-adguard/luci-app-adguardhome package/
rm -rf temp-luci-adguard  # 清理临时目录

# ========== 拉取官方最新版Aurora极光主题 ==========
# 删除feeds里自带的旧版Aurora主题
rm -rf feeds/luci/themes/luci-theme-aurora
rm -rf feeds/luci/applications/luci-app-aurora-config
# 克隆官方最新版源码到package目录（根目录直接带Makefile，无需中转）
git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone --depth=1 https://github.com/eamonxg/luci-app-aurora-config package/luci-app-aurora-config

# ========== Tailscale（异地组网） ==========
rm -rf feeds/packages/net/tailscale
git clone --depth=1 https://github.com/GuNanOvO/openwrt-tailscale temp-tailscale
cp -rf temp-tailscale/package/tailscale package/
rm -rf temp-tailscale

# Bandix（流量监控）
# git clone --depth=1 https://github.com/timsaya/openwrt-bandix package/openwrt-bandix
# git clone --depth=1 https://github.com/timsaya/luci-app-bandix package/luci-app-bandix


### PassWall & OpenClash ###

# 移除 OpenWrt Feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages

# 移除 OpenWrt Feeds 过时的LuCI版本
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-openclash
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
git clone --depth=1 https://github.com/vernesong/OpenClash package/luci-app-openclash

# 清理 PassWall 的 chnlist 规则文件
echo "baidu.com"  > package/luci-app-passwall/luci-app-passwall/root/usr/share/passwall/rules/chnlist


# 更新包源
./scripts/feeds install -f -a

# 重新加载配置
make defconfig

# 禁用Rust语言环境，解决LLVM 404报错（该方式无效，被下方真正修复替代）
# 保留作后备：防止配置里有 CONFIG_RUST=y 残留
sed -i 's/CONFIG_RUST=y/CONFIG_RUST=n/g' .config
echo "CONFIG_RUST=n" >> .config

# ========== 修复 Rust LLVM 404 报错（官方PR #28680 + #26643 方案） ==========
# 问题原因：rust编译时默认从ci-artifacts.rust-lang.org下载预编译LLVM
# 旧构建产物会被删除，导致404。官方修复：llvm.download-ci-llvm=false（本地编译LLVM）
# 另GitHub Actions环境下rust bootstrap会误判自己在rust上游CI环境中，额外报错。需 unset GITHUB_ACTIONS
if [ -f "feeds/packages/lang/rust/Makefile" ]; then
  # 方法1 - 修改 HOST_CONFIGURE_ARGS 中的 llvm.download-ci-llvm=true -> false
  sed -i 's|--set=llvm.download-ci-llvm=true|--set=llvm.download-ci-llvm=false|g' feeds/packages/lang/rust/Makefile
  # 方法2 - 兜底：如果上面没匹配到（比如参数格式有变化），直接把所有download-ci-llvm改为false
  sed -i 's|download-ci-llvm=true|download-ci-llvm=false|g' feeds/packages/lang/rust/Makefile
  # 方法3 - PR #26643：防止rust bootstrap在GitHub Actions环境下误判为上游rustc CI
  # 查找定义 Host/Compile 或执行 x.py 的行，前置 unset GITHUB_ACTIONS 和 CI
  sed -i '/x\.py/s|python3|env -u GITHUB_ACTIONS -u CI -u GITHUB_JOB -u RUNNER_ENV python3|g' feeds/packages/lang/rust/Makefile
  # 也在 HOST_CONFIGURE_CMD / Make 相关变量中清除（如果有的话）
fi

# 修复GMP host编译 ca-cert.pem 404报错
# GMP的download-ci-aws在bootstrap阶段尝试从Cirrus CI下载ca-cert.pem（返回404）
# GMP自身建议：disable download-ci-aws in your bootstrap.tmp
if [ -f "tools/gmp/Makefile" ]; then
  if grep -q 'HOST_CONFIGURE_CMD' tools/gmp/Makefile; then
    sed -i '/HOST_CONFIGURE_CMD/s|:=.*|:= printf "[aws]\\ndownload-ci-aws = false\\n" > bootstrap.tmp \&\& ./bootstrap --disable-download-ci-aws \&\& ./configure|' tools/gmp/Makefile
  else
    echo 'HOST_CONFIGURE_CMD:=printf "[aws]\ndownload-ci-aws = false\n" > bootstrap.tmp && ./bootstrap --disable-download-ci-aws && ./configure' >> tools/gmp/Makefile
  fi
fi
