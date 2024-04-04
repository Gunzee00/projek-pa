@extends('layouts.superadmin')

@section('content')
    <!-- Bordered Table -->
    <div class="card">
        <h3 class="card-header text-center">Laporan Masyarakat</h3>
        <div class="card-body">
            <div class="table-responsive text-nowrap">
                <table class="table table-bordered">
                    <thead>
                        <tr class="text-center">
                            <th>Nama Pelpor</th>
                            <th>Judul Laporan</th>
                            <th>Foto Pelapor</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($laporans as $laporan)
                            <tr class="text-center">
                                <td>
                                    <i class="fab fa-bootstrap fa-lg text-primary me-3"></i>
                                    <strong>{{ $laporan->user->full_name }}</strong>
                                </td>
                                <td>{{ $laporan->judul_pelaporan }}</td>
                                <td>
                                    <img src="{{ asset('assets/img/avatars/5.png') }}" alt="Avatar" class="rounded-circle"
                                        height="44px">
                                </td>
                                <td>
                                    <span class="badge bg-label-warning me-1">{{ $laporan->status }}</span>
                                </td>
                                <td class="text-center">
                                    <a href="{{ route('laporan-masyarakat.show', $laporan->id) }}" class="btn btn-sm btn-info">Detail</a>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="8">
                                    <h1>Tidak ada data laporan</h1>
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
        <div>
            {{ $laporans->links() }}
        </div>
    </div>
@endsection
