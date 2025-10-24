@extends('layouts.app')

@section('title', 'Dynamic Weekly Schedule')

@section('content')
<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="h3 mb-3">
                <i class="fas fa-calendar-alt me-2"></i>
                Dynamic Weekly Schedule
            </h1>

            @if(session('success'))
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            @endif

            @if(session('error'))
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>{{ session('error') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            @endif
        </div>
    </div>

    <!-- Settings Card -->
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-primary text-white">
            <h5 class="mb-0">
                <i class="fas fa-cog me-2"></i>
                Schedule Settings
            </h5>
        </div>
        <div class="card-body">
            <form action="{{ route('schedules.updateSettings') }}" method="POST" class="row g-3">
                @csrf
                @method('PUT')

                <div class="col-md-3">
                    <label for="start_time" class="form-label">Start Time</label>
                    <input type="time" 
                           class="form-control @error('start_time') is-invalid @enderror" 
                           id="start_time" 
                           name="start_time" 
                           value="{{ old('start_time', $settings->start_time->format('H:i')) }}" 
                           required>
                    @error('start_time')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="col-md-3">
                    <label for="end_time" class="form-label">End Time</label>
                    <input type="time" 
                           class="form-control @error('end_time') is-invalid @enderror" 
                           id="end_time" 
                           name="end_time" 
                           value="{{ old('end_time', $settings->end_time->format('H:i')) }}" 
                           required>
                    @error('end_time')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="col-md-3">
                    <label for="slot_interval" class="form-label">Slot Interval (minutes)</label>
                    <input type="number" 
                           class="form-control @error('slot_interval') is-invalid @enderror" 
                           id="slot_interval" 
                           name="slot_interval" 
                           value="{{ old('slot_interval', $settings->slot_interval) }}" 
                           min="15" 
                           max="240" 
                           required>
                    @error('slot_interval')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="col-md-3 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-save me-2"></i>Update Settings
                    </button>
                </div>
            </form>

            <hr class="my-3">

            <form action="{{ route('schedules.generateSlots') }}" method="POST">
                @csrf
                <button type="submit" class="btn btn-success" onclick="return confirm('This will generate time slots based on current settings. Continue?')">
                    <i class="fas fa-magic me-2"></i>Generate Time Slots
                </button>
                <small class="text-muted ms-2">
                    This will create slots for all days based on the settings above.
                </small>
            </form>
        </div>
    </div>

    <!-- Schedule Grid Card -->
    <div class="card shadow-sm">
        <div class="card-header bg-info text-white">
            <h5 class="mb-0">
                <i class="fas fa-table me-2"></i>
                Weekly Schedule Grid
            </h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-bordered table-hover mb-0 schedule-table">
                    <thead class="table-light">
                        <tr>
                            <th class="text-center align-middle" style="width: 100px;">Time</th>
                            @foreach($daysOfWeek as $day)
                                <th class="text-center">{{ $day }}</th>
                            @endforeach
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($scheduleGrid as $time => $days)
                            <tr>
                                <td class="text-center align-middle fw-bold bg-light">
                                    {{ \Carbon\Carbon::createFromFormat('H:i:s', $time)->format('h:i A') }}
                                </td>
                                @foreach($daysOfWeek as $day)
                                    @php
                                        $schedule = $days[$day] ?? null;
                                        $statusClass = match($schedule?->status ?? 'empty') {
                                            'available' => 'bg-success',
                                            'booked' => 'bg-danger',
                                            'pending' => 'bg-warning',
                                            default => 'bg-secondary'
                                        };
                                        $statusText = match($schedule?->status ?? 'empty') {
                                            'available' => 'Available',
                                            'booked' => 'Booked',
                                            'pending' => 'Pending',
                                            default => 'Empty'
                                        };
                                    @endphp
                                    <td class="text-center p-2 schedule-cell">
                                        @if($schedule)
                                            <div class="slot-card {{ $statusClass }} text-white p-2 rounded position-relative">
                                                <div class="slot-status">{{ $statusText }}</div>
                                                <div class="slot-quantity">
                                                    <small>Qty: {{ $schedule->quantity }}</small>
                                                </div>
                                                <button type="button" 
                                                        class="btn btn-sm btn-light mt-1 toggle-status-btn"
                                                        data-schedule-id="{{ $schedule->id }}"
                                                        title="Click to change status">
                                                    <i class="fas fa-sync-alt"></i>
                                                </button>
                                            </div>
                                        @else
                                            <div class="slot-card bg-secondary text-white p-2 rounded opacity-50">
                                                <small>No Slot</small>
                                            </div>
                                        @endif
                                    </td>
                                @endforeach
                            </tr>
                        @empty
                            <tr>
                                <td colspan="{{ count($daysOfWeek) + 1 }}" class="text-center py-5 text-muted">
                                    <i class="fas fa-info-circle fa-3x mb-3 d-block"></i>
                                    <p class="mb-0">No time slots generated yet. Use the "Generate Time Slots" button above.</p>
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Legend -->
    <div class="card shadow-sm mt-3">
        <div class="card-body">
            <h6 class="mb-3">
                <i class="fas fa-info-circle me-2"></i>Status Legend
            </h6>
            <div class="d-flex gap-4 flex-wrap">
                <div class="d-flex align-items-center">
                    <span class="badge bg-success me-2" style="width: 60px;">Available</span>
                    <small class="text-muted">Slot is available for booking</small>
                </div>
                <div class="d-flex align-items-center">
                    <span class="badge bg-warning me-2" style="width: 60px;">Pending</span>
                    <small class="text-muted">Booking is pending confirmation</small>
                </div>
                <div class="d-flex align-items-center">
                    <span class="badge bg-danger me-2" style="width: 60px;">Booked</span>
                    <small class="text-muted">Slot is fully booked</small>
                </div>
                <div class="d-flex align-items-center">
                    <span class="badge bg-secondary me-2" style="width: 60px;">Empty</span>
                    <small class="text-muted">No slot created for this time</small>
                </div>
            </div>
        </div>
    </div>
</div>

@push('styles')
<style>
    .schedule-table {
        font-size: 0.9rem;
    }

    .schedule-cell {
        min-width: 120px;
        vertical-align: middle;
    }

    .slot-card {
        min-height: 80px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        transition: transform 0.2s, box-shadow 0.2s;
    }

    .slot-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    }

    .slot-status {
        font-weight: bold;
        font-size: 0.9rem;
    }

    .slot-quantity {
        font-size: 0.8rem;
        margin-top: 4px;
    }

    .toggle-status-btn {
        font-size: 0.75rem;
        padding: 2px 8px;
    }

    .toggle-status-btn:hover {
        transform: rotate(180deg);
        transition: transform 0.3s;
    }

    .table-responsive {
        max-height: 600px;
        overflow-y: auto;
    }

    thead th {
        position: sticky;
        top: 0;
        z-index: 10;
        background-color: #f8f9fa !important;
    }
</style>
@endpush

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Handle toggle status button clicks
        document.querySelectorAll('.toggle-status-btn').forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                const scheduleId = this.dataset.scheduleId;
                toggleSlotStatus(scheduleId);
            });
        });

        function toggleSlotStatus(scheduleId) {
            fetch(`/schedules/${scheduleId}/toggle`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                    'Accept': 'application/json',
                },
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Reload page to show updated status
                    location.reload();
                } else {
                    alert('Error: ' + (data.message || 'Failed to update status'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while updating the slot status.');
            });
        }
    });
</script>
@endpush
@endsection
