# Dynamic Weekly Schedule Module for Laravel

A complete Laravel module for managing booking time slots with dynamic scheduling, Spatie permissions, and a beautiful Bootstrap UI.

## Features

- ✅ Dynamic time slot generation based on configurable settings
- ✅ Weekly schedule grid view (7 days x time slots)
- ✅ Color-coded status system (Available/Pending/Booked)
- ✅ Quantity management for each slot
- ✅ Spatie Laravel Permission integration
- ✅ Bootstrap 5 UI with responsive design
- ✅ AJAX status toggling
- ✅ Admin controls for time settings

## Installation Steps

### 1. Install Spatie Laravel Permission (if not already installed)

```bash
composer require spatie/laravel-permission
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan migrate
```

### 2. Copy Files to Your Laravel Project

Copy the files from this module to your Laravel project:

#### Models
- Copy `models/Schedule.php` to `app/Models/Schedule.php`
- Copy `models/ScheduleSetting.php` to `app/Models/ScheduleSetting.php`

#### Migrations
- Copy `migrations/2025_01_01_000001_create_schedules_table.php` to `database/migrations/`
- Copy `migrations/2025_01_01_000002_create_schedule_settings_table.php` to `database/migrations/`

#### Controller
- Copy `controllers/ScheduleController.php` to `app/Http/Controllers/ScheduleController.php`

#### Views
- Copy `views/schedules/index.blade.php` to `resources/views/schedules/index.blade.php`

#### Seeder
- Copy `seeder/SchedulePermissionSeeder.php` to `database/seeders/SchedulePermissionSeeder.php`

### 3. Add Routes

Add the routes from `routes/web.php` to your main `routes/web.php` file:

```php
use App\Http\Controllers\ScheduleController;

Route::middleware(['auth', 'permission:manage schedules'])->group(function () {
    Route::prefix('schedules')->name('schedules.')->group(function () {
        Route::get('/', [ScheduleController::class, 'index'])->name('index');
        Route::put('/settings', [ScheduleController::class, 'updateSettings'])->name('updateSettings');
        Route::post('/generate', [ScheduleController::class, 'generateSlots'])->name('generateSlots');
        Route::put('/{id}', [ScheduleController::class, 'updateSlot'])->name('updateSlot');
        Route::post('/{id}/toggle', [ScheduleController::class, 'toggleStatus'])->name('toggleStatus');
        Route::delete('/{id}', [ScheduleController::class, 'deleteSlot'])->name('deleteSlot');
    });
});
```

### 4. Run Migrations

```bash
php artisan migrate
```

### 5. Seed Permissions

```bash
php artisan db:seed --class=SchedulePermissionSeeder
```

Or add to your `DatabaseSeeder.php`:

```php
public function run(): void
{
    $this->call([
        SchedulePermissionSeeder::class,
    ]);
}
```

### 6. Update Your Layout

Make sure your layout file (`resources/views/layouts/app.blade.php`) has:

1. Bootstrap 5 CSS and JS
2. Font Awesome for icons
3. CSRF token meta tag
4. Sections for `@stack('styles')` and `@stack('scripts')`

Example layout structure:

```blade
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    
    <title>@yield('title', config('app.name'))</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    @stack('styles')
</head>
<body>
    <div id="app">
        <!-- Your navigation here -->
        
        <main class="py-4">
            @yield('content')
        </main>
    </div>
    
    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    @stack('scripts')
</body>
</html>
```

### 7. Assign Permission to Users

Assign the "manage schedules" permission to your admin users:

```php
use App\Models\User;

$user = User::find(1);
$user->givePermissionTo('manage schedules');

// Or assign the admin role
$user->assignRole('admin');
```

## Usage

1. **Access the Schedule Page**: Navigate to `/schedules` in your browser
2. **Configure Settings**: Set start time, end time, and slot interval
3. **Generate Slots**: Click "Generate Time Slots" to create slots for all days
4. **Manage Slots**: Click the toggle button on each slot to cycle through statuses
5. **View Status**: See color-coded status (Green=Available, Yellow=Pending, Red=Booked)

## Database Schema

### schedules table
- `id` - Primary key
- `day_name` - Day of the week (Monday-Sunday)
- `slot_time` - Time of the slot (HH:MM:SS)
- `status` - Enum: available, booked, pending
- `quantity` - Number of bookings available (default: 1)
- `timestamps` - Created/Updated timestamps

### schedule_settings table
- `id` - Primary key
- `start_time` - Schedule start time (default: 09:00)
- `end_time` - Schedule end time (default: 23:00)
- `slot_interval` - Minutes between slots (default: 60)
- `timestamps` - Created/Updated timestamps

## API Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/schedules` | Display schedule grid |
| PUT | `/schedules/settings` | Update time settings |
| POST | `/schedules/generate` | Generate time slots |
| POST | `/schedules/{id}/toggle` | Toggle slot status |
| PUT | `/schedules/{id}` | Update specific slot |
| DELETE | `/schedules/{id}` | Delete specific slot |

## Customization

### Change Status Colors
Edit the Blade view's match expressions in `resources/views/schedules/index.blade.php`

### Modify Time Intervals
Update the validation in `ScheduleController@updateSettings` to change min/max interval values

### Add More Days or Custom Days
Modify the `$daysOfWeek` array in `ScheduleController`

### Change Default Settings
Update the default values in the `schedule_settings` migration

## Requirements

- Laravel 10.x or 11.x
- PHP 8.1+
- Spatie Laravel Permission package
- Bootstrap 5
- Font Awesome 6

## License

This module is open-source and free to use in your Laravel projects.

## Support

For issues or questions, please check the code comments or Laravel documentation.
