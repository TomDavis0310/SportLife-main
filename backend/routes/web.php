<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

Route::get('/', function () {
    return view('welcome');
});
// Redirect default auth routes to Filament admin login to prevent missing route errors
Route::get('/login', fn () => redirect()->route('filament.admin.auth.login'))
    ->name('login');
Route::get('/register', fn () => redirect()->route('filament.admin.auth.login'))
    ->name('register');
