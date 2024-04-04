@extends('layouts.polisi')

@section('content')
    <!-- Content -->
    <div class="container-xxl flex-grow-1 container-p-y">
        <h4 class="fw-bold py-3 mb-4">
            {{ $title }}
        </h4>
        <div class="row">
            <div class="col-md-12">
                <div class="card mb-4">
                    <h5 class="card-header">Profile pelapor</h5>
                    <div class="card-body">
                        <div class="d-flex align-items-start align-items-sm-center gap-4">
                            <img src="{{ asset('assets/img/avatars/1.png') }}" alt="user-avatar" class="d-block rounded"
                                height="100" width="100" id="uploadedAvatar">
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="mb-3 col-md-6">
                                <label for="full_name" class="form-label">Nama Lengkap</label>
                                <input class="form-control" type="text" id="full_name" name="full_name"
                                    value="{{ $laporan->user->full_name }}" readonly>
                            </div>

                            <div class="mb-3 col-md-6">
                                <label for="lastName" class="form-label">Email</label>
                                <input class="form-control" type="text" name="lastName" id="lastName"
                                    value="{{ $laporan->user->email }}" readonly>
                            </div>
                            <div class="mb-3 col-md-6">
                                <label for="email" class="form-label">Nomor Handphone</label>
                                <input class="form-control" type="text" id="email" name="email"
                                    value="{{ $laporan->user->nohp }}" readonly>
                            </div>
                            <div class="mb-3 col-md-6">
                                <label for="organization" class="form-label">Username</label>
                                <input type="text" class="form-control" id="organization" name="organization"
                                    value="{{ $laporan->user->username }}" readonly>
                            </div>
                            <hr class="my-3">
                            <h5 class="card-header text-center">Isi Laporan</h5>
                            <div class="mb-3 col-md-6">
                                <label class="form-label" for="phoneNumber">Judul Laporan</label>
                                <div class="input-group input-group-merge">
                                    <input type="text" id="phoneNumber" name="phoneNumber" class="form-control"
                                        value="{{ $laporan->judul_pelaporan }}" readonly>
                                </div>
                            </div>
                            <div class="mb-3 col-md-6">
                                <label for="address" class="form-label">Lokasi Kejadian</label>
                                <input type="text" class="form-control" id="address" name="address"
                                    value="{{ $laporan->lokasi_kejadian }}" readonly>
                            </div>
                            <div class="mb-3 col-md-6">
                                <label for="address" class="form-label">Tanggal Kejadian</label>
                                <input type="text" class="form-control" id="address" name="address"
                                    value="{{ \Carbon\Carbon::parse($laporan->tanggal_kejadian)->format('l, j F Y H:i:s') }}"
                                    readonly>

                            </div>
                            <div class="mb-3 col-md-12">
                                <label for="state" class="form-label">Isi Laporan</label>
                                <textarea class="form-control" id="exampleFormControlTextarea1" rows="5" readonly>{{ $laporan->isi_laporan }}</textarea>
                            </div>
                        </div>
                        <form action="{{ route('polisi-laporan-masyarakat.proses', $laporan->id) }}" method="POST">
                            @csrf
                            <hr class="my-3">
                            <h5 class="card-header text-center">Pesan Anda</h5>
                            <div class="mb-3 col-md-12">
                                <div class="mb-3 col-md-12">
                                    <label for="state" class="form-label">Pesan Anda kepada Pelapor</label>
                                    <textarea class="form-control" name="catatan_petugas" rows="5">{{ $laporan->catatan_petugas }}</textarea>
                                </div>
                            </div>
                            <div class="mt-2">
                                <button type="submit" class="btn btn-primary me-2">Prosess</button>
                                <a href="{{ route('laporan-masyarakat.index') }}"
                                    class="btn btn-outline-secondary">Cancel</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
