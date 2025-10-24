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
        Schema::create('schedules', function (Blueprint $table) {
            $table->id();
            $table->string('day_name'); // Monday, Tuesday, etc.
            $table->time('slot_time');
            $table->enum('status', ['available', 'booked', 'pending'])->default('available');
            $table->integer('quantity')->default(1);
            $table->timestamps();

            // Add index for faster queries
            $table->index(['day_name', 'slot_time']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('schedules');
    }
};
