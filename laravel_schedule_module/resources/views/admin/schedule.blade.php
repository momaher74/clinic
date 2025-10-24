@php
    $locale = session('locale', app()->getLocale());
    app()->setLocale($locale);
@endphp

<!doctype html>
<html lang="{{ app()->getLocale() }}" dir="{{ app()->getLocale() == 'ar' ? 'rtl' : 'ltr' }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ __('admin.schedule_management') }}</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="p-6 bg-gray-100">
    <div class="max-w-7xl mx-auto">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-semibold">{{ __('admin.schedule_management') }}</h1>
            <form method="POST" action="{{ route('admin.schedule.locale') }}">
                @csrf
                <select name="locale" onchange="this.form.submit()" class="border rounded p-2">
                    <option value="en" {{ app()->getLocale()=='en' ? 'selected' : '' }}>English</option>
                    <option value="ar" {{ app()->getLocale()=='ar' ? 'selected' : '' }}>العربية</option>
                </select>
            </form>
        </div>

        <div class="bg-white shadow rounded p-4">
            <div class="mb-4">
                <form method="GET" class="flex items-center space-x-2">
                    <label class="text-sm">{{ __('admin.start') }}</label>
                    <input type="time" name="start" value="{{ $start }}" class="border rounded p-1" />
                    <label class="text-sm">{{ __('admin.end') }}</label>
                    <input type="time" name="end" value="{{ $end }}" class="border rounded p-1" />
                    <label class="text-sm">{{ __('admin.interval') }}</label>
                    <input type="number" name="interval" value="{{ $interval }}" class="border rounded p-1 w-20" />
                    <button class="bg-blue-600 text-white px-3 py-1 rounded">{{ __('admin.apply') }}</button>
                </form>
            </div>

            <table class="w-full table-auto border-collapse">
                <thead>
                    <tr>
                        <th class="border p-2">{{ __('admin.time') }}</th>
                        @foreach($days as $d)
                            <th class="border p-2 text-center">{{ __("admin.$d") }}</th>
                        @endforeach
                    </tr>
                </thead>
                <tbody>
                    @php
                        $startTime = \Carbon\Carbon::createFromTimeString($start);
                        $endTime = \Carbon\Carbon::createFromTimeString($end);
                        $period = \Carbon\CarbonPeriod::create($startTime, \Carbon\CarbonInterval::minutes($interval), $endTime);
                    @endphp

                    @foreach($period as $time)
                        <tr>
                            <td class="border p-2">{{ $time->format('H:i') }}</td>
                            @foreach($days as $d)
                                @php
                                    $slot = $schedules[$d]->firstWhere('time', $time->format('H:i')) ?? null;
                                    $date = \Carbon\Carbon::now()->next($d)->toDateString();
                                    $booked = 0;
                                    $available = $slot ? $slot->capacity : 0;
                                    if ($slot) {
                                        $booked = \App\Models\Booking::where('schedule_id', $slot->id)->where('date', $date)->where('status','booked')->sum('quantity');
                                        $available = max(0, $slot->capacity - $booked);
                                    }
                                @endphp
                                <td class="border p-2 text-center align-top">
                                    @if(!$slot)
                                        <div class="text-sm text-gray-400">{{ __('admin.not_configured') }}</div>
                                    @else
                                        <div class="mb-2">
                                            <div class="text-sm">{{ __('admin.status') }}: <strong>{{ $available>0 ? __('admin.available') : __('admin.booked') }}</strong></div>
                                            <div class="text-sm">{{ __('admin.quantity') }}: <strong>{{ $available }}</strong></div>
                                        </div>

                                        @if($available>0)
                                            <form method="POST" action="{{ route('admin.schedule.book') }}">
                                                @csrf
                                                <input type="hidden" name="schedule_id" value="{{ $slot->id }}" />
                                                <input type="date" name="date" value="{{ $date }}" />
                                                <input type="number" name="quantity" value="1" min="1" max="{{ $available }}" class="w-20" />
                                                <button class="bg-green-600 text-white px-2 py-1 rounded">{{ __('admin.book_now') }}</button>
                                            </form>
                                        @endif
                                    @endif
                                </td>
                            @endforeach
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
