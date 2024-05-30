<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Providers\RouteServiceProvider;
use Exception;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
class ProfileController extends Controller
{
    public function showUserInfo()
    {
        try {
            $user = Auth::user();
            return response()->json([
                'username' => $user->username,
                'nama_lengkap' => $user->nama_lengkap,
                'nomor_telepon' => $user->nomor_telepon,
                'alamat' => $user->alamat,
                'password_hash' => $user->password, // Gunakan field password yang berisi hash password
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Gagal mengambil informasi pengguna',
                'error' => $e->getMessage()
            ], 500);
        }
    }




    public function updateUser(Request $request)
    {
        try {
            $request->validate([
                'username' => 'required|unique:users,username,' . Auth::id(),
                'nama_lengkap' => 'required',
                'nomor_telepon' => 'required|unique:users,nomor_telepon,' . Auth::id(),
                'alamat' => 'required',
                // 'password' => 'required'
            ]);
    
            $user = Auth::user();
            $user->username = $request->input('username');
            $user->nama_lengkap = $request->input('nama_lengkap');
            $user->nomor_telepon = $request->input('nomor_telepon');
            $user->alamat = $request->input('alamat');
            // $user->password = bcrypt($request->input('password'));
            $user->save();
    
            return response()->json([
                'message' => 'Profil sudah diubah',
                'data' => $user
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation error',
                'errors' => $e->validator->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to update user information',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    
    
}