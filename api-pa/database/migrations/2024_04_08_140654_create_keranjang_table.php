<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateKeranjangTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('keranjang', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('id_produk');
            $table->integer('jumlah');
            $table->string('nama_produk');
            $table->string('satuan');
            $table->decimal('harga', 10, 2);
            $table->string('gambar');
            $table->decimal('total_harga', 10, 2);
            
            // Foreign key constraint
            $table->foreign('user_id')->references('id')->on('users');
            $table->foreign('id_produk')->references('id')->on('produk');
            
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('keranjang');
    }
}
