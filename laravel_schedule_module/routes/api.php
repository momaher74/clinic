<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ScheduleApiController;

Route::middleware('auth:api')->group(function(){
    Route::get('/schedule/days', [ScheduleApiController::class, 'days']);
    Route::get('/schedule/slots', [ScheduleApiController::class, 'slots']);
});
