<?php
// Simple API stub for module — must be secured and integrated into Issabel's permissions.
header('Content-Type: application/json');
session_start();
$logged_in = isset($_SESSION['amp_user']);
if (!$logged_in) {
    http_response_code(401);
    echo json_encode(['error' => 'not_authenticated']);
    exit;
}
$action = $_GET['action'] ?? '';
switch ($action) {
    case 'zones':
        // TODO: query DB for zones
        echo json_encode(['zones'=>[]]);
        break;
    case 'operators':
        echo json_encode(['operators'=>[]]);
        break;
    case 'playlists':
        echo json_encode(['playlists'=>[]]);
        break;
    case 'schedules':
        echo json_encode(['schedules'=>[]]);
        break;
    case 'logs':
        echo json_encode(['logs'=>[]]);
        break;
    default:
        echo json_encode(['message'=>'pbx-scheduler-paging api']);
}
?>