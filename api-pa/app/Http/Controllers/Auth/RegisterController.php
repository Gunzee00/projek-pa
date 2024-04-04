<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use App\Models\User;
use Illuminate\Foundation\Auth\RegistersUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class RegisterController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Register Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles the registration of new users as well as their
    | validation and creation. By default this controller uses a trait to
    | provide this functionality without requiring any additional code.
    |
    */

    use RegistersUsers;

    /**
     * Where to redirect users after registration.
     *
     * @var string
     */
    protected $redirectTo = RouteServiceProvider::HOME;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('guest');
    }

    /**
     * Get a validator for an incoming registration request.
     *
     * @param  array  $data
     * @return \Illuminate\Contracts\Validation\Validator
     */
    protected function validator(array $data)
    {
        $validatedData = $request->validate([
            'username' => 'required|unique:users',
            'nama_lengkap' => 'required',
            'nomor_telepon' => 'required',
            'alamat' => 'required',
            'password' => 'required',
            'role' => 'required'
        ]);
    }

    /**
     * Create a new user instance after a valid registration.
     *
     * @param  array  $data
     * @return \App\Models\User
     */
    protected function create(array $data)
    {
        return User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);
    }

    public function registerApi(Request $request)
    {
        // Validasi input
        $request->validate([
            'nama_lengkap' => 'required|string',
            'username' => 'required|string|unique:users',
            'nomor_telepon' => 'required|string|unique:users',
            'alamat' => 'required|string',
            'password' => 'required|string|min:8',
        ]);

        // Buat user baru
        $user = new User();
        $user->nama_lengkap = $request->input('nama_lengkap');
        $user->username = $request->input('username');
        $user->nomor_telepon = $request->input('nomor_telepon');
        $user->alamat = $request->input('alamat');
        $user->role = $request->input('role');
        $user->password = bcrypt($request->input('password')); // Menggunakan bcrypt untuk hashing password

        // Set default akses
        // $user->role = 'pembeli';

        

        // Simpan user ke database
        $user->save();

        return response()->json(['message' => 'Registrasi berhasil', 'user' => $user], 201);
    }
}
