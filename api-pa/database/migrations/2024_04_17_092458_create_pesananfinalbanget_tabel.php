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
            $table->id('id_pesanan');
            $table->unsignedBigInteger('user_id_pembeli');
            $table->unsignedBigInteger('user_id_penjual');
            $table->string('status');
            $table->unsignedBigInteger('id_produk');
            $table->integer('jumlah');
            $table->string('nama_produk');
            $table->string('satuan');
            $table->decimal('harga', 10, 2);
            $table->string('gambar')->nullable();
            $table->decimal('total_harga', 10, 2);
            $table->timestamps();

            // Add foreign key constraints
            $table->foreign('user_id_pembeli')->references('id')->on('users');
            $table->foreign('user_id_penjual')->references('id_pembuat')->on('produk');
            // Assuming 'produk' table has 'id_pembuat' as the column name for the creator ID
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
