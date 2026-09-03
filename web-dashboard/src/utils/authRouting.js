const DASHBOARD_PATH_BY_ROLE = Object.freeze({
    kader: "/kader/dashboard",
    puskesmas: "/puskesmas/dashboard",
});

export const isWebRole = (role) =>
    Object.hasOwn(DASHBOARD_PATH_BY_ROLE, role);

export const dashboardPathForRole = (role) =>
    DASHBOARD_PATH_BY_ROLE[role] ?? null;

export const resolveAuthNavigation = ({
    isLoggedIn,
    role,
    requiresAuth = false,
    requiresGuest = false,
    requiredRole = null,
    currentPath,
}) => {
    const dashboardPath = dashboardPathForRole(role);

    if (isLoggedIn && !dashboardPath) {
        return {
            clearSession: true,
            redirect: currentPath === "/login" ? null : "/login",
        };
    }
    if (requiresAuth && !isLoggedIn) {
        return { clearSession: false, redirect: "/login" };
    }
    if (requiresGuest && isLoggedIn) {
        return { clearSession: false, redirect: dashboardPath };
    }
    if (requiredRole && role !== requiredRole) {
        return {
            clearSession: false,
            redirect: dashboardPath ?? "/login",
        };
    }
    return { clearSession: false, redirect: null };
};
