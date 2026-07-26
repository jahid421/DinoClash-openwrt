module("luci.controller.mihomo", package.seeall)

function index()
    entry({"admin", "services", "mihomo"}, alias("admin", "services", "mihomo", "main"), _("DinoClash 🦕"), 60)
    entry({"admin", "services", "mihomo", "main"}, template("mihomo/main"), _("DinoClash 🦕"), 1).leaf = true
end
