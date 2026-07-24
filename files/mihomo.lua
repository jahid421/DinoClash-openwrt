module("luci.controller.mihomo", package.seeall)

function index()
    entry({"admin", "services", "mihomo"}, alias("admin", "services", "mihomo", "main"), _("Mihomo"), 60)
    entry({"admin", "services", "mihomo", "main"}, template("mihomo/main"), _("Mihomo"), 1).leaf = true
end
