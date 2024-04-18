<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePesanan extends Migration
{
    public function up()
    {
        Schema::create('pesanan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id_pembeli')->constrained('users');
            $table->foreignId('user_id_penjual')->constrained('users');
            $table->string('status');
            $table->unsignedBigInteger('id_produk');
            $table->integer('jumlah');
            $table->string('nama_produk');
            $table->string('satuan');
            $table->decimal('harga', 10, 2);
            $table->string('gambar')->nullable();
            $table->decimal('total_harga', 10, 2);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('pesanan');
    }
}
