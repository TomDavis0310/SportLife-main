<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BadgeController;
use App\Http\Controllers\Api\CompetitionController;
use App\Http\Controllers\Api\HighlightController;
use App\Http\Controllers\Api\MatchController;
use App\Http\Controllers\Api\MissionController;
use App\Http\Controllers\Api\NewsController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PredictionController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\RewardController;
use App\Http\Controllers\Api\SocialAuthController;
use App\Http\Controllers\Api\SocialController;
use App\Http\Controllers\Api\SponsorController;
use App\Http\Controllers\Api\TeamController;
use App\Http\Controllers\Api\TournamentController;
use App\Http\Controllers\Api\TeamManagementController;
use App\Http\Controllers\Api\JournalistController;
use App\Http\Controllers\Api\ChampionPredictionController;
use App\Http\Controllers\Api\MatchSchedulingController;
use App\Http\Controllers\Api\MatchAutoUpdateController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::prefix('v1')->group(function () {

    // Authentication
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
        Route::post('reset-password', [AuthController::class, 'resetPassword']);

        // Social auth
        Route::post('social/{provider}', [SocialAuthController::class, 'redirect']);
        Route::get('social/{provider}/callback', [SocialAuthController::class, 'callback']);
        Route::post('social/{provider}/token', [SocialAuthController::class, 'handleMobileToken']);
    });

    // Competitions (public)
    Route::get('competitions', [CompetitionController::class, 'index']);
    Route::get('competitions/{competition}', [CompetitionController::class, 'show']);
    Route::get('competitions/{competition}/seasons', [CompetitionController::class, 'seasons']);
    Route::get('competitions/{competition}/standings', [CompetitionController::class, 'standings']);
    Route::get('competitions/{competition}/rounds', [CompetitionController::class, 'rounds']);
    Route::get('competitions/{competition}/matches', [CompetitionController::class, 'matches']);
    Route::get('rounds/{round}/matches', [CompetitionController::class, 'roundMatches']);

    // Tournament schedule (public)
    Route::get('tournaments/{season}/schedule', [TournamentController::class, 'getSchedule']);

    // Matches (public)
    Route::get('matches', [MatchController::class, 'index']);
    Route::get('matches/today', [MatchController::class, 'today']);
    Route::get('matches/live', [MatchController::class, 'live']);
    Route::get('matches/upcoming', [MatchController::class, 'upcoming']);
    Route::get('matches/{match}', [MatchController::class, 'show']);
    Route::get('matches/{match}/events', [MatchController::class, 'events']);
    Route::get('matches/{match}/head-to-head', [MatchController::class, 'headToHead']);
    Route::get('matches/{match}/highlights', [HighlightController::class, 'matchHighlights']);

    // Highlights (public)
    Route::get('highlights', [HighlightController::class, 'index']);
    Route::get('highlights/{highlight}', [HighlightController::class, 'show']);

    // Teams (public)
    Route::get('teams', [TeamController::class, 'index']);
    Route::get('teams/{team}', [TeamController::class, 'show']);
    Route::get('teams/{team}/players', [TeamController::class, 'players']);
    Route::get('teams/{team}/matches', [TeamController::class, 'matches']);
    Route::get('teams/{team}/upcoming', [TeamController::class, 'upcomingMatches']);
    Route::get('teams/{team}/results', [TeamController::class, 'recentResults']);
    Route::get('teams/{team}/stats', [TeamController::class, 'statistics']);

    // News (public)
    Route::get('news', [NewsController::class, 'index']);
    Route::get('news/featured', [NewsController::class, 'featured']);
    Route::get('news/{news}', [NewsController::class, 'show'])->name('news.show');
    Route::get('news/{news}/comments', [NewsController::class, 'comments']);
    Route::get('news/{news}/related', [NewsController::class, 'related']);

    // Leaderboard (public)
    Route::get('leaderboard', [PredictionController::class, 'leaderboard']);

    // Badges (public)
    Route::get('badges', [BadgeController::class, 'index']);
    Route::get('badges/categories', [BadgeController::class, 'categories']);
    Route::get('badges/category/{category}', [BadgeController::class, 'byCategory']);

    // Sponsors (public)
    Route::get('sponsors', [SponsorController::class, 'index']);
    Route::get('sponsors/{sponsor}', [SponsorController::class, 'show']);
    Route::get('sponsors/{sponsor}/campaigns', [SponsorController::class, 'campaigns']);
    Route::get('campaigns', [SponsorController::class, 'allCampaigns']);
    Route::get('campaigns/{campaign}', [SponsorController::class, 'campaignDetails']);

    // Rewards (public listing)
    Route::get('rewards', [RewardController::class, 'index']);
    Route::get('rewards/{reward}', [RewardController::class, 'show']);

    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {

        // Auth
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/user', [AuthController::class, 'user']);
        Route::post('auth/refresh', [AuthController::class, 'refreshToken']);

        // Profile
        Route::prefix('profile')->group(function () {
            Route::get('/', [ProfileController::class, 'show']);
            Route::put('/', [ProfileController::class, 'update']);
            Route::post('avatar', [ProfileController::class, 'updateAvatar']);
            Route::put('password', [ProfileController::class, 'changePassword']);
            Route::get('points', [ProfileController::class, 'pointHistory']);
            Route::get('stats', [ProfileController::class, 'statistics']);
            Route::get('badges', [ProfileController::class, 'badges']);
        });

        // Daily bonus
        Route::post('daily-bonus', [AuthController::class, 'claimDailyBonus']);

        // Predictions
        Route::prefix('predictions')->group(function () {
            Route::get('/', [PredictionController::class, 'index']);
            Route::post('/', [PredictionController::class, 'store']);
            Route::get('my-rank', [PredictionController::class, 'myRank']);
            Route::get('friends-leaderboard', [PredictionController::class, 'friendsLeaderboard']);
            Route::get('{prediction}', [PredictionController::class, 'show']);
            Route::put('{prediction}', [PredictionController::class, 'update']);
        });
        Route::get('matches/{match}/prediction', [MatchController::class, 'userPrediction']);
        Route::get('matches/{match}/predictions', [PredictionController::class, 'matchPredictions']);

        // Champion Predictions (dự đoán đội vô địch)
        Route::prefix('champion-predictions')->group(function () {
            Route::get('seasons', [ChampionPredictionController::class, 'availableSeasons']);
            Route::get('seasons/{season}/teams', [ChampionPredictionController::class, 'seasonTeams']);
            Route::get('seasons/{season}/stats', [ChampionPredictionController::class, 'seasonStats']);
            Route::get('seasons/{season}/champion', [ChampionPredictionController::class, 'seasonChampion']);
            Route::get('seasons/{season}/my-prediction', [ChampionPredictionController::class, 'mySeasonPrediction']);
            Route::get('champions', [ChampionPredictionController::class, 'allChampions']);
            Route::get('leaderboard', [ChampionPredictionController::class, 'leaderboard']);
            Route::get('my-rank', [ChampionPredictionController::class, 'myRank']);
            Route::get('my-predictions', [ChampionPredictionController::class, 'myPredictions']);
            Route::post('/', [ChampionPredictionController::class, 'store']);
            Route::get('{championPrediction}', [ChampionPredictionController::class, 'show']);
            Route::put('{championPrediction}', [ChampionPredictionController::class, 'update']);
        });

        // Teams (protected actions)
        Route::post('teams/{team}/follow', [TeamController::class, 'follow']);
        Route::delete('teams/{team}/follow', [TeamController::class, 'unfollow']);

        // News (protected actions)
        Route::post('news/{news}/comments', [NewsController::class, 'addComment']);
        Route::delete('comments/{comment}', [NewsController::class, 'deleteComment']);
        Route::post('news/{news}/like', [NewsController::class, 'like']);
        Route::delete('news/{news}/like', [NewsController::class, 'unlike']);

        // Rewards
        Route::post('rewards/{reward}/redeem', [RewardController::class, 'redeem']);
        Route::get('redemptions', [RewardController::class, 'history']);
        Route::get('redemptions/{redemption}', [RewardController::class, 'redemptionDetails']);

        // Sponsors/Campaigns (protected actions)
        Route::post('campaigns/{campaign}/interact', [SponsorController::class, 'interact']);
        Route::get('my-interactions', [SponsorController::class, 'myInteractions']);

        // Badges
        Route::get('my-badges', [BadgeController::class, 'myBadges']);
        Route::get('badges/progress', [BadgeController::class, 'progress']);
        Route::get('badges/{badge}', [BadgeController::class, 'show']);

        // Missions
        Route::prefix('missions')->group(function () {
            Route::get('today', [MissionController::class, 'today']);
            Route::post('{mission}/progress', [MissionController::class, 'updateProgress']);
            Route::post('{mission}/claim', [MissionController::class, 'claim']);
            Route::get('history', [MissionController::class, 'history']);
            Route::get('weekly', [MissionController::class, 'weeklySummary']);
        });

        // Social
        Route::prefix('social')->group(function () {
            Route::get('search', [SocialController::class, 'searchUsers']);
            Route::get('users/{user}', [SocialController::class, 'userProfile']);
            Route::post('users/{user}/friend-request', [SocialController::class, 'sendFriendRequest']);
            Route::post('users/{user}/accept', [SocialController::class, 'acceptFriendRequest']);
            Route::post('users/{user}/reject', [SocialController::class, 'rejectFriendRequest']);
            Route::delete('users/{user}/friend', [SocialController::class, 'removeFriend']);
            Route::get('friend-requests', [SocialController::class, 'friendRequests']);
            Route::get('friends', [SocialController::class, 'friends']);
            Route::get('followed-teams', [SocialController::class, 'followedTeams']);
            Route::get('feed', [SocialController::class, 'feed']);
        });

        // Notifications
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index']);
            Route::get('unread-count', [NotificationController::class, 'unreadCount']);
            Route::post('{notification}/read', [NotificationController::class, 'markAsRead']);
            Route::post('read-all', [NotificationController::class, 'markAllAsRead']);
            Route::delete('{notification}', [NotificationController::class, 'destroy']);
            Route::delete('read', [NotificationController::class, 'deleteRead']);
            Route::get('settings', [NotificationController::class, 'getSettings']);
            Route::put('settings', [NotificationController::class, 'updateSettings']);
            Route::post('fcm-token', [NotificationController::class, 'registerFcmToken']);
        });

        // Tournament Management (Sponsors & Managers)
        Route::prefix('tournaments')->group(function () {
            Route::get('/', [TournamentController::class, 'index']);
            Route::post('/', [TournamentController::class, 'store']); // Sponsor only
            Route::get('{season}', [TournamentController::class, 'show']); // Get season details
            Route::post('{season}/register', [TournamentController::class, 'registerTeam']); // Manager only
            Route::get('{season}/registrations', [TournamentController::class, 'getRegistrations']); // Sponsor only
            Route::post('{season}/registrations/{team}/approve', [TournamentController::class, 'approveRegistration']); // Sponsor only
            Route::post('{season}/registrations/{team}/reject', [TournamentController::class, 'rejectRegistration']); // Sponsor only
            Route::post('{season}/lock-registration', [TournamentController::class, 'lockRegistration']); // Sponsor only
            Route::post('{season}/unlock-registration', [TournamentController::class, 'unlockRegistration']); // Sponsor only
            Route::get('{season}/schedule', [TournamentController::class, 'getSchedule']); // Public - view schedule
            Route::post('{season}/schedule/preview', [TournamentController::class, 'previewSchedule']); // Sponsor only
            Route::post('{season}/schedule/generate', [TournamentController::class, 'generateSchedule']); // Sponsor only
            Route::delete('{season}/schedule', [TournamentController::class, 'clearSchedule']); // Sponsor only
            Route::put('{season}/matches/{match}', [TournamentController::class, 'updateMatch']); // Sponsor only
        });

        // Live Match Management (Sponsors)
        Route::prefix('live-matches')->group(function () {
            Route::get('/', [\App\Http\Controllers\Api\LiveMatchController::class, 'getMatches']);
            Route::get('{match}', [\App\Http\Controllers\Api\LiveMatchController::class, 'getMatch']);
            Route::post('{match}/start', [\App\Http\Controllers\Api\LiveMatchController::class, 'startMatch']);
            Route::put('{match}/status', [\App\Http\Controllers\Api\LiveMatchController::class, 'updateStatus']);
            Route::put('{match}/score', [\App\Http\Controllers\Api\LiveMatchController::class, 'updateScore']);
            Route::post('{match}/events', [\App\Http\Controllers\Api\LiveMatchController::class, 'addEvent']);
            Route::delete('{match}/events/{event}', [\App\Http\Controllers\Api\LiveMatchController::class, 'deleteEvent']);
            Route::post('{match}/end', [\App\Http\Controllers\Api\LiveMatchController::class, 'endMatch']);
        });

        // Team Management (Club Managers)
        Route::prefix('my-team')->group(function () {
            Route::get('/', [TeamManagementController::class, 'getMyTeam']);
            Route::put('/', [TeamManagementController::class, 'update']);
            Route::post('players', [TeamManagementController::class, 'addPlayer']);
            Route::put('players/{player}', [TeamManagementController::class, 'updatePlayer']);
            Route::delete('players/{player}', [TeamManagementController::class, 'removePlayer']);
            Route::post('staff', [TeamManagementController::class, 'addStaff']);
            Route::delete('staff/{staff}', [TeamManagementController::class, 'removeStaff']);
        });

        // Journalist Management (Journalists)
        Route::prefix('journalist')->group(function () {
            Route::get('articles', [JournalistController::class, 'myArticles']);
            Route::post('articles', [JournalistController::class, 'store']);
            Route::put('articles/{news}', [JournalistController::class, 'update']);
            Route::post('articles/{news}/update', [JournalistController::class, 'update']); // For file uploads
            Route::delete('articles/{news}', [JournalistController::class, 'destroy']);
            Route::post('articles/{news}/toggle-publish', [JournalistController::class, 'togglePublish']);
            Route::get('statistics', [JournalistController::class, 'statistics']);
            Route::get('sources', [JournalistController::class, 'getSources']);
            Route::post('fetch-news', [JournalistController::class, 'fetchNews']);
            Route::get('auto-fetched', [JournalistController::class, 'autoFetchedNews']);
            Route::delete('clean-old', [JournalistController::class, 'cleanOldNews']);
        });

        // Match Scheduling (Admin/Manager)
        Route::prefix('scheduling')->group(function () {
            Route::get('seasons', [MatchSchedulingController::class, 'seasons']);
            Route::get('seasons/{season}', [MatchSchedulingController::class, 'seasonDetails']);
            Route::get('seasons/{season}/rounds', [MatchSchedulingController::class, 'rounds']);
            Route::post('seasons/{season}/rounds', [MatchSchedulingController::class, 'createRound']);
            Route::get('rounds/{round}/matches', [MatchSchedulingController::class, 'roundMatches']);
            Route::post('seasons/{season}/preview', [MatchSchedulingController::class, 'previewSchedule']);
            Route::post('seasons/{season}/generate', [MatchSchedulingController::class, 'generateSchedule']);
            Route::delete('seasons/{season}/clear', [MatchSchedulingController::class, 'clearSchedule']);
            Route::get('seasons/{season}/conflicts', [MatchSchedulingController::class, 'checkConflicts']);
            Route::post('matches', [MatchSchedulingController::class, 'createMatch']);
            Route::put('matches/{match}', [MatchSchedulingController::class, 'updateMatch']);
            Route::post('matches/{match}/reschedule', [MatchSchedulingController::class, 'rescheduleMatch']);
            Route::post('matches/{match}/swap', [MatchSchedulingController::class, 'swapTeams']);
            Route::delete('matches/{match}', [MatchSchedulingController::class, 'deleteMatch']);
        });

        // Match Auto Update (Admin/Sponsor)
        Route::prefix('match-auto-update')->group(function () {
            Route::get('pending', [MatchAutoUpdateController::class, 'getPendingMatches']);
            Route::post('trigger', [MatchAutoUpdateController::class, 'triggerAutoUpdate']);
            Route::post('matches/{match}', [MatchAutoUpdateController::class, 'updateSingleMatch']);
        });
    });
});

// Health check
Route::get('/health', fn() => response()->json(['status' => 'ok', 'timestamp' => now()]));
