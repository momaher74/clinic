<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = ['schedule_id', 'user_id', 'date', 'time', 'status', 'quantity'];

    protected $casts = [
        'date' => 'date',
        'time' => 'string',
    ];

    public function schedule()
    {
        return $this->belongsTo(Schedule::class);
    }

    public function user()
    {
        return $this->belongsTo(\App\Models\User::class);
    }
}
