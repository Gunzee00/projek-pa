<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('barang', function (Blueprint $table) {
            $table->id('id_barang');
            $table->integer('id_pembuat'); 
            $table->string('nama_barang');
            $table->decimal('harga', 10, 2);
            $table->string('gambar')->nullable();
            $table->text('deskripsi')->nullable();
            $table->string('satuan');
            $table->integer('minimal_pemesanan')->default(1);
            $table->integer('stok')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('items_tabel');
    }
};
