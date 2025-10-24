<?php

namespace App\Http\Controllers;

use App\Models\Schedule;
use App\Models\ScheduleSetting;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ScheduleController extends Controller
{
    /**
     * Days of the week
     */
    private array $daysOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
    ];

    /**
     * Create a new controller instance.
     */
    public function __construct()
    {
        $this->middleware('permission:manage schedules');
    }

    /**
     * Display the schedule management page.
     */
    public function index()
    {
        $settings = ScheduleSetting::current();
        $schedules = Schedule::orderBy('day_name')->orderBy('slot_time')->get();
        
        // Generate time slots based on settings
        $timeSlots = $this->generateTimeSlots($settings);
        
        // Organize schedules by day and time
        $scheduleGrid = $this->organizeScheduleGrid($schedules, $timeSlots);

        return view('schedules.index', [
            'settings' => $settings,
            'timeSlots' => $timeSlots,
            'scheduleGrid' => $scheduleGrid,
            'daysOfWeek' => $this->daysOfWeek,
        ]);
    }

    /**
     * Update schedule settings.
     */
    public function updateSettings(Request $request)
    {
        $validated = $request->validate([
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'slot_interval' => 'required|integer|min:15|max:240',
        ]);

        $settings = ScheduleSetting::current();
        $settings->update($validated);

        return redirect()->route('schedules.index')
            ->with('success', 'Schedule settings updated successfully!');
    }

    /**
     * Generate time slots based on settings.
     */
    public function generateSlots(Request $request)
    {
        $settings = ScheduleSetting::current();
        $timeSlots = $this->generateTimeSlots($settings);

        DB::beginTransaction();
        try {
            // Clear existing schedules (optional - you may want to keep booked ones)
            // Schedule::truncate();

            // Generate slots for each day
            foreach ($this->daysOfWeek as $day) {
                foreach ($timeSlots as $slot) {
                    // Check if slot already exists
                    $existingSlot = Schedule::where('day_name', $day)
                        ->where('slot_time', $slot)
                        ->first();

                    if (!$existingSlot) {
                        Schedule::create([
                            'day_name' => $day,
                            'slot_time' => $slot,
                            'status' => 'available',
                            'quantity' => 1,
                        ]);
                    }
                }
            }

            DB::commit();

            return redirect()->route('schedules.index')
                ->with('success', 'Time slots generated successfully!');
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->route('schedules.index')
                ->with('error', 'Failed to generate slots: ' . $e->getMessage());
        }
    }

    /**
     * Update slot status.
     */
    public function updateSlot(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => 'required|in:available,booked,pending',
            'quantity' => 'nullable|integer|min:1',
        ]);

        $schedule = Schedule::findOrFail($id);
        $schedule->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Slot updated successfully!',
            'data' => $schedule
        ]);
    }

    /**
     * Toggle slot status (cycle through available -> pending -> booked -> available).
     */
    public function toggleStatus(Request $request, $id)
    {
        $schedule = Schedule::findOrFail($id);

        $statusCycle = [
            'available' => 'pending',
            'pending' => 'booked',
            'booked' => 'available',
        ];

        $schedule->status = $statusCycle[$schedule->status];
        $schedule->save();

        return response()->json([
            'success' => true,
            'message' => 'Status toggled successfully!',
            'data' => $schedule
        ]);
    }

    /**
     * Delete a specific slot.
     */
    public function deleteSlot($id)
    {
        $schedule = Schedule::findOrFail($id);
        $schedule->delete();

        return response()->json([
            'success' => true,
            'message' => 'Slot deleted successfully!'
        ]);
    }

    /**
     * Generate time slots array based on settings.
     *
     * @param ScheduleSetting $settings
     * @return array
     */
    private function generateTimeSlots(ScheduleSetting $settings): array
    {
        $slots = [];
        $start = Carbon::createFromFormat('H:i:s', $settings->start_time);
        $end = Carbon::createFromFormat('H:i:s', $settings->end_time);
        $interval = $settings->slot_interval;

        $current = $start->copy();

        while ($current->lessThan($end)) {
            $slots[] = $current->format('H:i:s');
            $current->addMinutes($interval);
        }

        return $slots;
    }

    /**
     * Organize schedules into a grid format.
     *
     * @param $schedules
     * @param array $timeSlots
     * @return array
     */
    private function organizeScheduleGrid($schedules, array $timeSlots): array
    {
        $grid = [];

        foreach ($timeSlots as $time) {
            foreach ($this->daysOfWeek as $day) {
                $schedule = $schedules->where('day_name', $day)
                    ->where('slot_time', $time)
                    ->first();

                $grid[$time][$day] = $schedule;
            }
        }

        return $grid;
    }
}
