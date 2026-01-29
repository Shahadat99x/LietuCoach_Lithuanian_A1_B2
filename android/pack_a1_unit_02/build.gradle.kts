plugins {
    id("com.android.asset-pack")
}

assetPack {
    packName.set("pack_a1_unit_02")
    // On-demand delivery - downloaded when user unlocks/requests
    dynamicDelivery {
        deliveryType.set("on-demand")
    }
}
