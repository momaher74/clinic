<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ScheduleSetting extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'start_time',
        'end_time',
        'slot_interval',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i',
        'slot_interval' => 'integer',
    ];

    /**
     * Get the current settings (singleton pattern)
     *
     * @return ScheduleSetting
     */
    public static function current(): ScheduleSetting
    {
        return self::firstOrCreate(
            ['id' => 1],
            [
                'start_time' => '09:00:00',
                'end_time' => '23:00:00',
                'slot_interval' => 60,
            ]
        );
    }
}
