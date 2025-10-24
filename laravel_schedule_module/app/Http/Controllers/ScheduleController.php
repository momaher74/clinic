<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Schedule;
use App\Models\Booking;
use Carbon\Carbon;

class ScheduleController extends Controller
{
    public function index(Request $request)
    {
        $start = $request->input('start', '09:00');
        $end = $request->input('end', '23:00');
        $interval = (int) $request->input('interval', 60);

        $days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
        $schedules = Schedule::orderBy('time')->get()->groupBy('weekday');

        return view('admin.schedule', compact('schedules','days','start','end','interval'));
    }

    // other admin functions handled in Admin\ScheduleController in module
}
