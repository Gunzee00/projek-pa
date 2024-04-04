<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pelaporan_ke_dinas', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->string('judul_pelaporan');
            $table->string('visibility');
            $table->text('isi_laporan');
            $table->timestamp('tanggal_kejadian');
            $table->string('lokasi_kejadian');
            $table->string('status')->default('Laporan diterima');
            $table->text('catatan_petugas')->nullable();
            $table->timestamps();
        });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pelaporan_ke_dinas');
    }
};
