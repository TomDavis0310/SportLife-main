<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\HighlightResource;
use App\Models\FootballMatch;
use App\Models\MatchHighlight;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HighlightController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = MatchHighlight::query()
            ->with([
                'match.homeTeam',
                'match.awayTeam',
                'match.round.season.competition',
            ])
            ->orderByDesc('published_at')
            ->orderByDesc('created_at');

        if ($request->boolean('featured')) {
            $query->where('is_featured', true);
        }

        if ($request->filled('match_id')) {
            $query->where('match_id', $request->integer('match_id'));
        }

        if ($request->filled('competition_id')) {
            $query->whereHas('match.round.season', function ($q) use ($request) {
                $q->where('competition_id', $request->integer('competition_id'));
            });
        }

        if ($request->filled('limit') && ! $request->filled('page')) {
            $limit = max(1, (int) $request->get('limit', 10));
            $highlights = $query->limit($limit)->get();

            return response()->json([
                'success' => true,
                'data' => HighlightResource::collection($highlights),
            ]);
        }

        $highlights = $query->paginate($request->integer('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => HighlightResource::collection($highlights),
            'meta' => [
                'current_page' => $highlights->currentPage(),
                'last_page' => $highlights->lastPage(),
                'per_page' => $highlights->perPage(),
                'total' => $highlights->total(),
            ],
        ]);
    }

    public function show(MatchHighlight $highlight): JsonResponse
    {
        $highlight->load(['match.homeTeam', 'match.awayTeam', 'match.round.season.competition']);

        return response()->json([
            'success' => true,
            'data' => new HighlightResource($highlight),
        ]);
    }

    public function matchHighlights(FootballMatch $match, Request $request): JsonResponse
    {
        $limit = max(1, (int) $request->get('limit', 10));
        $highlights = $match->highlights()
            ->limit($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => HighlightResource::collection($highlights),
        ]);
    }
}
