<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class SchedulePermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create permission
        $permission = Permission::firstOrCreate(
            ['name' => 'manage schedules'],
            ['guard_name' => 'web']
        );

        // Assign permission to admin role (adjust role name as needed)
        $adminRole = Role::firstOrCreate(
            ['name' => 'admin'],
            ['guard_name' => 'web']
        );

        $adminRole->givePermissionTo($permission);

        $this->command->info('Schedule permission created and assigned to admin role.');
    }
}
