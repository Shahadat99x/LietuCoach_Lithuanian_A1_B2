plugins {
    id("com.android.asset-pack")
}

assetPack {
    packName.set("pack_a1_unit_01")
    // Install-time delivery - available immediately after app install
    dynamicDelivery {
        deliveryType.set("install-time")
    }
}
