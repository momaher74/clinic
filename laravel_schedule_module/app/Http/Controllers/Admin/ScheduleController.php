<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Schedule;
use App\Models\Booking;
use Carbon\Carbon;

class ScheduleController extends Controller
{
    public function index(Request $request)
    {
        // fetch settings - for simplicity hardcode range; in prod store in db
        $start = $request->input('start', '09:00');
        $end = $request->input('end', '23:00');
        $interval = (int) $request->input('interval', 60); // minutes

        // get all schedules grouped by weekday
        $schedules = Schedule::orderBy('time')->get()->groupBy('weekday');

        // days list
        $days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];

        return view('admin.schedule', compact('schedules','days','start','end','interval'));
    }

    public function book(Request $request)
    {
        $request->validate([
            'schedule_id' => 'required|exists:schedules,id',
            'date' => 'required|date',
            'quantity' => 'nullable|integer|min:1'
        ]);

        $schedule = Schedule::findOrFail($request->schedule_id);

        // compute already booked quantity for that date and time
        $booked = Booking::where('schedule_id', $schedule->id)
            ->where('date', $request->date)
            ->where('status', 'booked')
            ->sum('quantity');

        $qty = $request->input('quantity', 1);
        if (($booked + $qty) > $schedule->capacity) {
            return back()->withErrors(['msg' => __('admin.slot_full')]);
        }

        $booking = Booking::create([
            'schedule_id' => $schedule->id,
            'user_id' => auth()->id(),
            'date' => $request->date,
            'time' => $schedule->time,
            'status' => 'booked',
            'quantity' => $qty
        ]);

        return back()->with('success', __('admin.booked_success'));
    }

    public function setLocale(Request $request)
    {
        $locale = $request->input('locale', 'en');
        session(['locale' => $locale]);
        app()->setLocale($locale);
        return redirect()->back();
    }
}
