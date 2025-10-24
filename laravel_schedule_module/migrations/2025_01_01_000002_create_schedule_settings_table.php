<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('schedule_settings', function (Blueprint $table) {
            $table->id();
            $table->time('start_time')->default('09:00:00');
            $table->time('end_time')->default('23:00:00');
            $table->integer('slot_interval')->default(60); // minutes
            $table->timestamps();
        });

        // Insert default settings
        DB::table('schedule_settings')->insert([
            'start_time' => '09:00:00',
            'end_time' => '23:00:00',
            'slot_interval' => 60,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('schedule_settings');
    }
};
