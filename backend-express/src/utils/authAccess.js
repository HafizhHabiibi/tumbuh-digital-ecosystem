const ALLOWED_ROLES_BY_PLATFORM = Object.freeze({
    web: Object.freeze(["kader", "puskesmas"]),
    mobile: Object.freeze(["orang_tua"]),
});

export const normalizeAuthPlatform = (platform) => platform ?? "web";

export const isRoleAllowedOnPlatform = (platform, role) => {
    const normalizedPlatform = normalizeAuthPlatform(platform);
    return ALLOWED_ROLES_BY_PLATFORM[normalizedPlatform]?.includes(role) ?? false;
};

