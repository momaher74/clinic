Quick setup:

1. Copy `laravel_schedule_module` contents to your Laravel project root.
2. Run composer require spatie/laravel-permission
3. Run php artisan migrate
4. Seed permissions php artisan db:seed --class=\Database\Seeders\SchedulePermissionSeeder
5. Create some weekly slots via tinker or seeder:

\App\Models\Schedule::create(['weekday'=>'monday','time'=>'09:00','capacity'=>3]);
