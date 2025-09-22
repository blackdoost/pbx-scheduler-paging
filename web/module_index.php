<?php
// pbx-scheduler-paging Issabel module stub
session_start();
// Very small auth check — in real module integrate with Issabel auth
$logged_in = isset($_SESSION['amp_user']);
if (!$logged_in) {
    echo "<h3>Please login to Issabel to use this module.</h3>";
    exit;
}

echo "<h2>PBX Scheduler & Paging (Module)</h2>";
echo "<ul>";
echo "<li><a href=\"api.php?action=zones\">Manage Zones</a></li>";
echo "<li><a href=\"api.php?action=playlists\">Playlists & Tracks</a></li>";
echo "<li><a href=\"api.php?action=schedules\">Schedules</a></li>";
echo "<li><a href=\"api.php?action=operators\">Operators</a></li>";
echo "<li><a href=\"api.php?action=logs\">Logs</a></li>";
echo "</ul>";

// placeholder UI links. Real module needs proper Issabel packaging and integration.
?>