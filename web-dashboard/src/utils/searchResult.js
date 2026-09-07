export const formatSearchResultCount = ({ visible, total, search }) => {
    const suffix = String(search || "").trim() ? "hasil" : "data";
    return `${visible} dari ${total} ${suffix}`;
};
