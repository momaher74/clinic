<?php

use App\Http\Controllers\ScheduleController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Schedule Routes
|--------------------------------------------------------------------------
|
| Add these routes to your main routes/web.php file
|
*/

Route::middleware(['auth', 'permission:manage schedules'])->group(function () {
    Route::prefix('schedules')->name('schedules.')->group(function () {
        // Main schedule page
        Route::get('/', [ScheduleController::class, 'index'])->name('index');
        
        // Update settings
        Route::put('/settings', [ScheduleController::class, 'updateSettings'])->name('updateSettings');
        
        // Generate slots
        Route::post('/generate', [ScheduleController::class, 'generateSlots'])->name('generateSlots');
        
        // Update individual slot
        Route::put('/{id}', [ScheduleController::class, 'updateSlot'])->name('updateSlot');
        
        // Toggle slot status
        Route::post('/{id}/toggle', [ScheduleController::class, 'toggleStatus'])->name('toggleStatus');
        
        // Delete slot
        Route::delete('/{id}', [ScheduleController::class, 'deleteSlot'])->name('deleteSlot');
    });
});
