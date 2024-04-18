<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('pesanan', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id_pembeli');
            $table->unsignedBigInteger('user_id_penjual');
            $table->string('status', 50);
            $table->unsignedBigInteger('id_produk');
            $table->integer('jumlah');
            $table->string('nama_produk', 255);
            $table->string('satuan', 50);
            $table->decimal('harga', 10, 2);
            $table->string('gambar', 255)->nullable();
            $table->decimal('total_harga', 10, 2);
            $table->timestamps();

            $table->foreign('user_id_pembeli')->references('id')->on('users');
            $table->foreign('user_id_penjual')->references('id')->on('users');
            $table->foreign('id_produk')->references('id_produk')->on('produk');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('pesanan');
    }
};
