<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Schedule;
use App\Models\Booking;
use Carbon\Carbon;

class ScheduleApiController extends Controller
{
    public function days(Request $request)
    {
        $locale = $request->header('Accept-Language', 'en');
        app()->setLocale($locale);

        $days = [
            'monday' => __('admin.monday'),
            'tuesday' => __('admin.tuesday'),
            'wednesday' => __('admin.wednesday'),
            'thursday' => __('admin.thursday'),
            'friday' => __('admin.friday'),
            'saturday' => __('admin.saturday'),
            'sunday' => __('admin.sunday'),
        ];

        return response()->json(['days' => array_values($days)]);
    }

    public function slots(Request $request)
    {
        $locale = $request->header('Accept-Language', 'en');
        app()->setLocale($locale);

        $day = strtolower($request->query('day', 'monday'));
        if (!in_array($day, ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'])) {
            return response()->json(['message' => __('admin.invalid_day')], 422);
        }

        // find next date for that weekday
        $date = Carbon::now()->next($day);

        // fetch weekly slots for the weekday
        $schedules = Schedule::where('weekday', $day)->orderBy('time')->get();

        $slots = $schedules->map(function($s) use ($date){
            $booked = Booking::where('schedule_id', $s->id)
                ->where('date', $date->toDateString())
                ->where('status', 'booked')
                ->sum('quantity');

            $available = max(0, $s->capacity - $booked);
            $status = $available > 0 ? 'available' : 'booked';

            return [
                'time' => substr($s->time,0,5),
                'status' => __("admin.$status"),
                'quantity' => $available,
            ];
        });

        return response()->json([
            'day' => __("admin.$day"),
            'date' => $date->toDateString(),
            'slots' => $slots,
        ]);
    }
}
