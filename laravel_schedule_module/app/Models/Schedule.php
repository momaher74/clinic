<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Schedule extends Model
{
    use HasFactory;

    protected $fillable = ['weekday', 'time', 'capacity'];

    protected $casts = [
        'time' => 'string',
    ];

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }
}
